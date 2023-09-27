---
title: castile-rpc框架：通信协议的设计和编解码器的实现
tags:
	- RPC
categories:
	- RPC
---

现在需要建立客户端和服务端之间的通信机制了，主要内容有：

- 服务消费者实现协议编码，向服务提供者发送调用数据。
- 服务提供者收到数据后解码，然后向服务消费者发送响应数据，暂时忽略 RPC 请求是如何被调用的。
- 服务消费者收到响应数据后成功返回。



## 1、RPC 通信方案设计



![1695565921880](castile-rpc框架：通信协议的设计和编解码器的实现/1695565921880.png)





## 2、自定义RPC通信协议

协议是服务消费者和服务提供者之间通信的基础，主流的 RPC 框架都会自定义通信协议，相比于 HTTP、HTTPS、JSON 等通用的协议，自定义协议可以实现更好的性能、扩展性以及安全性。 

### 自定义协议要素

- 魔数，用来在第一时间判定是否是无效数据包
- 版本号，可以支持协议的升级
- 序列化算法，消息正文到底采用哪种序列化反序列化方式，可以由此扩展，例如：json、protobuf、hessian、jdk
- 状态： 失败还是成功？ 可选
- 消息类型，是请求、响应？这个 跟业务相关
- 请求序号，为了双工通信，提供异步能力
- 正文长度
- 消息正文

```xml
+---------------------------------------------------------------+

| 魔数 2byte | 协议版本号 1byte | 序列化算法 1byte | 报文类型 1byte  |

+---------------------------------------------------------------+

| 状态 1byte |        消息 ID 8byte     |      数据长度 4byte     |

+---------------------------------------------------------------+

|                   数据内容 （长度不定）                          |

+---------------------------------------------------------------+
```

我们把协议分为协议头 Header 和协议体 Body 两个部分。协议头 Header 包含魔数、协议版本号、序列化算法、报文类型、状态、消息 ID、数据长度，协议体 Body 只包含数据内容部分，数据内容的长度是不固定的。RPC 请求和响应都可以使用该协议进行通信，对应协议实体类的定义如下所示： 

```java 

@Data
public class CastileRpcProtocol<T> implements Serializable {
    /**
     * 消息头
     */
    private MessageHeader messageHeader;

    /**
     * 消息体
     */
    private T body;
}
```

```java

@Data
public class MessageHeader implements Serializable {

    private short magic;
    private byte version;
    private byte serialization;
    private byte msgType;
    private byte status;
    private long requestId;
    private int msgLen;
}

```



## 3、序列化算法选型 

目前比较常用的序列化算法包括 Json、Kryo、Hessian、Protobuf 等，这些第三方序列化算法都比 Java 原生的序列化操作都更加高效。 我们设计了一个 RPC 序列化顶层接口， 所有的序列化算法都需要实现这个接口；

```java

public interface RpcSerialization {
    /**
     * 序列化
     *
     * @param obj 待序列化数据
     * @param <T> 序列化数据的类型
     * @return 序列化后的字节流
     * @throws IOException IO异常
     */
    <T> byte[] serialize(T obj) throws IOException;

    /**
     * 反序列化
     *
     * @param buf   数据
     * @param clazz 类型
     * @param <T>   类型
     * @return
     * @throws IOException
     */
    <T> T deserialize(byte[] buf, Class<T> clazz) throws IOException;

}

```

 我们为 RpcSerialization 提供了 HessianSerialization 和 JsonSerialization 两种类型的实现，为此，可以提供一个序列化工厂来切换不同的序列化算法

```java
public class SerializationFactory {
    public static RpcSerialization getRpcSerialization(byte type){

        SerializationTypeEnum typeEnum = SerializationTypeEnum.findSerializationType(type);

        switch (typeEnum){
            case HESSIAN:
                return new HessianSerialization();
            case JSON:
                return new JsonSerialization();
            default:
                throw new IllegalArgumentException("serialization type is illegal, " + type);
        }
    }
}
```



## 4、通信协议的编码器

Netty 提供了两个最为常用的编解码抽象基类 MessageToByteEncoder 和 ByteToMessageDecoder，帮助我们很方便地扩展实现自定义协议。 

```java
public class MessageEncoder extends MessageToByteEncoder<CastileRpcProtocol> {


    /*
   +---------------------------------------------------------------+
   | 魔数 2byte | 协议版本号 1byte | 序列化算法 1byte | 报文类型 1byte  |
   +---------------------------------------------------------------+
   | 状态 1byte |        消息 ID 8byte     |      数据长度 4byte     |
   +---------------------------------------------------------------+
   |                   数据内容 （长度不定）                          |
   +---------------------------------------------------------------+
   */
    @Override
    protected void encode(ChannelHandlerContext channelHandlerContext, CastileRpcProtocol message, ByteBuf byteBuf) throws Exception {
        MessageHeader messageHeader = message.getMessageHeader();
        // 魔数
        byteBuf.writeShort(messageHeader.getMagic());
        // 协议版本号
        byteBuf.writeByte(messageHeader.getVersion());
        // 序列化算法
        byteBuf.writeByte(messageHeader.getSerialization());
        // 报文类型
        byteBuf.writeByte(messageHeader.getMsgType());
        // 状态
        byteBuf.writeByte(messageHeader.getStatus());
        // 消息id
        byteBuf.writeLong(messageHeader.getRequestId());

        // 序列化
        RpcSerialization rpcSerialization = SerializationFactory.getRpcSerialization(messageHeader.getSerialization());
        byte[] body = rpcSerialization.serialize(message.getBody());
        // 数据长度
        byteBuf.writeInt(body.length);
        byteBuf.writeBytes(body);
    }
}

```

在服务消费者或者服务提供者调用 writeAndFlush() 将数据写给对方前，都已经封装成 RpcRequest 或者 RpcResponse，所以可以采用 CastileRpcProtocol作为 RPC Encoder 编码器能够支持的编码类型。 



## 5、 通信协议的解码器

 解码器 相比于编码器 要复杂很多，解码器的目标是将字节流数据解码为消息对象，并传递给下一个 Inbound 处理器。整个解码过程有几个要点要特别注意： 

- 只有当 ByteBuf 中内容大于协议头 Header 的固定的 18 字节时，才开始读取数据。

- 即使已经可以完整读取出协议头 Header，但是协议体 Body 有可能还未就绪。所以在刚开始读取数据时，需要使用 markReaderIndex() 方法标记读指针位置，当 ByteBuf 中可读字节长度小于协议体 Body 的长度时，再使用 resetReaderIndex() 还原读指针位置，说明现在 ByteBuf 中可读字节还不够一个完整的数据包。

  > 这个其实也可以使用**LengthFieldBasedFrameDecoder**来处理粘包和半包问题

- 根据不同的报文类型 MsgType，需要反序列化出不同的协议体对象。在 RPC 请求调用的场景下，服务提供者需要将协议体内容反序列化成 MiniRpcRequest 对象；在 RPC 结果响应的场景下，服务消费者需要将协议体内容反序列化成 MiniRpcResponse 对象。

```java

@Slf4j
public class MessageDecoder extends ByteToMessageDecoder {
    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf, List<Object> list) throws Exception {
        // 消息小于头长度，不完整数据
        if (byteBuf.readableBytes() < ProtocolConstants.HEADER_TOTAL_LEN) {
            log.error("message length valid failed! please check request data");
            return;
        }
        byteBuf.markReaderIndex();
        // 魔数
        short magic = byteBuf.readShort();
        // 魔数不匹配，不是本系统消息
        if (magic != ProtocolConstants.MAGIC) {
            throw new IllegalArgumentException("magic number is illegal, " + magic);
        }
        byte version = byteBuf.readByte();
        byte serializeType = byteBuf.readByte();
        byte msgType = byteBuf.readByte();
        byte status = byteBuf.readByte();
        long requestId = byteBuf.readLong();
        int dataLength = byteBuf.readInt();
        if (byteBuf.readableBytes() < dataLength) {
            log.error("data readableBytes less than data length!");
            byteBuf.resetReaderIndex();
            return;
        }
        byte[] data = new byte[dataLength];
        byteBuf.readBytes(data);
        // 获取消息类型
        MsgType byTpye = MsgType.findByType(msgType);
        if (byTpye == null) {
            throw new IllegalArgumentException("msgType number is illegal, " + msgType);
        }
        MessageHeader header = new MessageHeader();
        header.setMagic(magic);
        header.setVersion(version);
        header.setSerialization(serializeType);
        header.setStatus(status);
        header.setRequestId(requestId);
        header.setMsgType(msgType);
        header.setMsgLen(dataLength);

        // 反序列化
        RpcSerialization rpcSerialization = SerializationFactory.getRpcSerialization(serializeType);
        switch (byTpye) {
            case REQUEST:
                RpcRequest rpcRequest = rpcSerialization.deserialize(data, RpcRequest.class);
                if (rpcRequest != null) {
                    CastileRpcProtocol<RpcRequest> castileRpcProtocol = new CastileRpcProtocol<>();
                    castileRpcProtocol.setMessageHeader(header);
                    castileRpcProtocol.setBody(rpcRequest);
                    list.add(castileRpcProtocol);
                }
                break;
            case RESPONSE:
                RpcResponse rpcResponse = rpcSerialization.deserialize(data, RpcResponse.class);
                if (rpcResponse != null) {
                    CastileRpcProtocol<RpcResponse> castileRpcProtocol = new CastileRpcProtocol<>();
                    castileRpcProtocol.setMessageHeader(header);
                    castileRpcProtocol.setBody(rpcResponse);
                    list.add(castileRpcProtocol);
                }
            case HEARTBEAT:
                // TODO
                break;
        }
    }
}

```



## 6、请求和响应处理

消费者调用RPC请求后，服务端通过解码器将二进制的数据解码成CastileRpcProtocol<RpcRequest>对象，再传递给RpcRequestHandler处理器执行rpc调用。 RpcRequestHandler 也是一个 Inbound 处理器，它并不需要承担解码工作，所以 RpcRequestHandler 直接继承 SimpleChannelInboundHandler 即可，然后重写 channelRead0() 方法，具体实现如下： 

```java

@Slf4j
public class RpcRequestHandler extends SimpleChannelInboundHandler<CastileRpcProtocol<RpcRequest>> {
    private final Map<String, Object> rpcServiceMap;

    public RpcRequestHandler(Map<String, Object> rpcServiceMap) {
        this.rpcServiceMap = rpcServiceMap;
    }


    @Override
    protected void channelRead0(ChannelHandlerContext ctx, CastileRpcProtocol<RpcRequest> msg) throws Exception {
        // 执行rpc调用比较耗时，因此放在业务线程池中去处理
        RpcRequestProcessor.submitRequest(() -> {
            CastileRpcProtocol<RpcResponse> rpcProtocol = new CastileRpcProtocol<>();
            RpcResponse rpcResponse = new RpcResponse();
            MessageHeader messageHeader = msg.getMessageHeader();
            messageHeader.setMsgType((byte) MsgType.RESPONSE.getType());
            try {
                RpcRequest request = msg.getBody();
                String serviceKey = RpcServiceHelper.buildServiceKey(request.getClassName(), request.getServiceVersion());

                // 获取bean对象
                Object serviceBean = rpcServiceMap.get(serviceKey);
                if (serviceBean == null) {
                    // 不存在
                    throw new RuntimeException(String.format("service not exist: %s:%s", request.getClassName(), request.getMethodName()));
                }
                Class<?> serviceClazz = serviceBean.getClass();
                String methodName = request.getMethodName();
                Object[] params = request.getParams();
                Class<?>[] parameterTypes = request.getParameterTypes();
                FastClass fastClass = FastClass.create(serviceClazz);
                int index = fastClass.getIndex(methodName, parameterTypes);
                Object result = fastClass.invoke(index, serviceBean, params);

                // 写回到response中
                rpcResponse.setData(result);
                messageHeader.setStatus((byte) MsgStatus.SUCCESS.getCode());
                rpcProtocol.setBody(rpcResponse);
                rpcProtocol.setMessageHeader(messageHeader);
            } catch (Throwable throwable) {
                messageHeader.setStatus((byte) MsgStatus.FAIL.getCode());
                rpcResponse.setMessage(throwable.toString());
                log.error("process request {} error", messageHeader.getRequestId(), throwable);
            }

            ctx.writeAndFlush(rpcProtocol);
        });

    }
}

```

 服务消费者在发起调用时，维护了请求 requestId 和 RpcFuture的映射关系，RpcResponseHandler 会根据请求的 requestId 找到对应发起调用的 RpcFuture，然后为 RpcFuture 设置响应结果。 

```java
public class RpcResponseHandler extends SimpleChannelInboundHandler<CastileRpcProtocol<RpcResponse>> {
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, CastileRpcProtocol<RpcResponse> msg) throws Exception {
        long requestId = msg.getMessageHeader().getRequestId();
        RpcFuture<RpcResponse> responseRpcFuture = RpcRequestHolder.REQUEST_MAP.remove(requestId);
        responseRpcFuture.getPromise().setSuccess(msg.getBody());

    }
}
```

```java
@Data
public class RpcFuture<T> {

    private Promise<T> promise;

    private long timeout;

    public RpcFuture(Promise<T> promise, long timeout) {
        this.promise = promise;
        this.timeout = timeout;
    }
}

```

























