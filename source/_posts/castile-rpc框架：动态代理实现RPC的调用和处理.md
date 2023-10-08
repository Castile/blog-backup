---
title: castile-rpc框架：动态代理实现RPC的调用和处理
tags:
  - RPC
categories:
  - RPC
toc: true
date: 2023-10-08 22:55:44
---


在一个RPC框架中，动态代理可以屏蔽rpc调用时低层的网络通讯、服务发现、负载均衡等具体细节。 使用 RPC 框架的时候，只需要调用接口方法，然后就拿到了返回结果。这些都是通过动态代理去实现的。

## 代理模式

代理模式的优势是可以很好地遵循设计模式中的开闭原则，对扩展开发，对修改关闭。不需要关注目标类的实现细节，通过代理模式可以在不修改目标类的情况下，增强目标类功能的行为。 

动态代理是一种代理模式，它提供了一种能够在运行时动态构建代理类以及动态调用目标方法的机制。为什么称为动态是因为代理类和被代理对象的关系是在运行时决定的，代理类可以看作是对被代理对象的包装，对目标方法的调用是通过代理类来完成的。所以通过代理模式可以有效地将服务提供者和服务消费者进行解耦，隐藏了 RPC 调用的具体细节。

## 服务消费者动态代理实现

我们使用@RPCReference注解来标注一个服务端接口，通过一个自定义的RpcReferenceBean完成了所有执行方法的拦截。 RpcReferenceBean 中 init() 方法是代理对象的创建入口，代理对象创建如下所示：

```java
 /**
     * 初始化bean，返回代理对象
     *
     * @throws Exception
     */
    public void init() throws Exception {
        RegistryService registryService = RegistryFactory.getInstance(registryAddr, RegistryType.valueOf(registryType));
        this.object = Proxy.newProxyInstance(
                interfaceClass.getClassLoader(),
                new Class<?>[]{interfaceClass},
                new RpcInvokerProxy(serviceVersion, timeout, registryService)
        );
    }
```

RpcInvokerProxy 处理器是实现动态代理逻辑的核心所在，其中包含 RPC 调用时底层网络通信、服务发现、负载均衡等具体细节 

```java
public class RpcInvokerProxy implements InvocationHandler {
    private final String serviceVersion;
    private final Long timeout;
    private final RegistryService registryService;

    public RpcInvokerProxy(String serviceVersion, long timeout, RegistryService registryService) {
        this.serviceVersion = serviceVersion;
        this.timeout = timeout;
        this.registryService = registryService;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        CastileRpcProtocol<RpcRequest> rpcProtocol = new CastileRpcProtocol<>();
        // 消息头
        MessageHeader messageHeader = new MessageHeader();
        // 消息id
        long requestId = RpcRequestHolder.REQUEST_ID_GEN.incrementAndGet();
        // 魔数
        messageHeader.setMagic(ProtocolConstants.MAGIC);
        // 版本
        messageHeader.setVersion(ProtocolConstants.VERSION);
        // 序列化算法
        messageHeader.setSerialization((byte) SerializationTypeEnum.HESSIAN.getType());
        // 消息类型
        messageHeader.setMsgType((byte) MsgType.REQUEST.getType());
        messageHeader.setStatus((byte) MsgStatus.SUCCESS.getCode());

        rpcProtocol.setMessageHeader(messageHeader);

        // 消息正文
        RpcRequest rpcRequest = new RpcRequest();
        rpcRequest.setServiceVersion(serviceVersion);
        rpcRequest.setClassName(method.getDeclaringClass().getName());
        rpcRequest.setMethodName(method.getName());
        rpcRequest.setParameterTypes(method.getParameterTypes());
        rpcRequest.setParams(args);

        rpcProtocol.setBody(rpcRequest);

        // 创建rpc客户端，发送消息进行rpc调用
        RpcConsumer consumer = new RpcConsumer();

        RpcFuture<RpcResponse> rpcFuture = new RpcFuture<>(new DefaultPromise<>(new DefaultEventLoop()), timeout);
        RpcRequestHolder.REQUEST_MAP.put(requestId, rpcFuture);
        consumer.sendMessage(rpcProtocol, registryService);
        return rpcFuture.getPromise().get(rpcFuture.getTimeout(), TimeUnit.MILLISECONDS).getData();
    }
}
```

invoke() 方法的核心流程主要分为三步：构造 RPC 协议对象、发起 RPC 远程调用、等待 RPC 调用执行结果。 

发起 RPC 调用之前，我们需要找到最合适的服务节点，直接调用注册中心服务 RegistryService 的 discovery() 方法即可，默认是采用一致性 Hash 算法实现的服务发现 。为了尽可能使所有服务节点收到的请求流量更加均匀，需要为 discovery() 提供一个 invokerHashCode，一般可以采用 RPC 服务接口参数列表中第一个参数的 hashCode 作为参考依据。找到服务节点地址后，接下来通过 Netty 建立 TCP 连接，然后调用 writeAndFlush() 方法将数据发送到远端服务节点。 

```java
public void sendMessage(CastileRpcProtocol<RpcRequest> protocolRequest, RegistryService registryService) throws Exception {
        RpcRequest request = protocolRequest.getBody();
        Object[] params = request.getParams();
        String serviceKey = RpcServiceHelper.buildServiceKey(request.getMethodName(), request.getServiceVersion());
        int invokeHashCode = params.length > 0 ? params[0].hashCode() : serviceKey.hashCode();
        // 找到需要发送到哪个服务实例
        ServiceMetaData serviceMetaData = registryService.discovery(serviceKey, invokeHashCode);
        if (serviceMetaData != null) {
            ChannelFuture channelFuture = bootstrap.connect(serviceMetaData.getServiceAddr(), serviceMetaData.getPort()).sync();
            channelFuture.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture channelFuture) throws Exception {
                    if (channelFuture.isSuccess()) {
                        log.info("connect rpc service {} om port {} success!", serviceMetaData.getServiceAddr(), serviceMetaData.getPort());
                    } else {
                        log.error("connect rpc server {} on port {} failed.", serviceMetaData.getServiceAddr(), serviceMetaData.getPort());
                        channelFuture.cause().printStackTrace();
                        eventLoopGroup.shutdownGracefully();
                    }
                }
            });
            channelFuture.channel().writeAndFlush(protocolRequest);
        }
    }
```

 发送RPC远程调用后，使用Promise机制等待拿到结果。

Promise 模式本质是一种异步编程模型，我们可以先拿到一个查看任务执行结果的凭证，不必等待任务执行完毕，当我们需要获取任务执行结果时，再使用凭证提供的相关接口进行获取。 

## 服务提供者反射调用实现

消费者通过netty发送消息给服务端后，rpc的请求数据经过解码器解码成CastileRpcProtocol对象后，再交由RpcRequestHandler执行rpcx请求调用：

```java
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

rpcServiceMap 中存放着服务提供者所有对外发布的服务接口，我们可以通过服务名和服务版本找到对应的服务接口。通过服务接口、方法名、方法参数列表、参数类型列表，我们一般可以使用反射的方式执行方法调用。为了加速服务接口调用的性能，我们采用 Cglib 提供的 FastClass 机制直接调用方法，Cglib 中 MethodProxy 对象就是采用了 FastClass 机制，它可以和 Method 对象完成同样的事情，但是相比于反射性能更高。 

FastClass 机制并没有采用反射的方式调用被代理的方法，而是运行时动态生成一个新的 FastClass 子类，向子类中写入直接调用目标方法的逻辑。同时该子类会为代理类分配一个 int 类型的 index 索引，FastClass 即可通过 index 索引定位到需要调用的方法。 

# 实现源码

https://gitee.com/hongliangzhu/castile-rpc