---
title: castile-rpc框架：服务治理-服务发现和负载均衡
tags:
  - RPC
categories:
  - RPC
toc: true
date: 2023-09-27 23:25:00
---


在一个分布式系统中，每个服务都有多个实例，如果服务实例节点出现负载比较高，那么可能会导致该节点上面的请求处理超时，影响可用性。so，一个良好的rpc框架需要 实现合理的负载均衡算法。

## 注册中心

服务消费者在发起请求之前都需要根据需要调用的服务去服务中心去找那些服务端实例，而且每个服务都有上线和下线的概念，因此消费端还需要感知服务提供者的实例变化，在rpc框架中，一般使用注册中心来实现服务的发现和注册。

主流的注册中心有zookeeper、Eureka、Etcd？Consul、Nacos等， 高可用的注册中心对 RPC 框架至关重要。说到高可用自然离不开 CAP 理论，一致性 Consistency、可用性 Availability 和分区容忍性 Partition tolerance 是无法同时满足的，注册中心一般分为 **CP 类型注册中心**和 **AP 类型注册中心** 。

● 一致性：指所有节点在同一时刻的数据完全一致。

● 可用性：指服务一直可用，而且响应时间正常。例如，不管什么时候访问X节点和Y节点都可以正常获取数据值，而不会出现问题。

● 分区容错性：指在遇到某节点或网络分区故障时，仍然能够对外提供满足一致性和可用性的服务。例如X节点和Y节点出现故障，但是依然可以很好地对外提供服务 

**CAP的取舍**:

1、 满足CA舍弃P，也就是满足一致性和可用性，舍弃分区容错性。这也就意味着你的系统不是分布式的了，因为分布式就是把功能分开部署到不同的机器上。

2、满足CP舍弃A，也就是满足一致性和分区容错性，舍弃可用性。这也就意味着你的系统允许有一段时间访问失效等，不会出现数据不一致的情况。

3、满足AP舍弃C，也就是满足可用性和分区容错性，舍弃一致性。这也就意味着你的系统在并发访问的时候可能会出现数据不一致的情况。

在分布式系统中，为了避免单点故障，分区容错是不可避免的，所以对于注册中心来说只能从CP（优先保证数据一致性）、AP（优先保证数据可用性）中根据你的业务场景选择一种。

 使用最为广泛的 Zookeeper 就是 CP 类型的注册中心，集群中会有一个节点作为 Leader，如果 Leader 节点挂了，会重新进行 Leader 选举，ZooKeeper 保证了所有节点的强一致性，但是在 Leader 选举的过程中是无法对外提供服务的，牺牲了部分可用性。Eureka 是典型的 AP 类型注册中心，在实现服务发现的场景下有很大的优势，整个集群是不存在 Leader、Flower 概念的，如果其中一个节点挂了，请求会立刻转移到其他节点上。可能会存在的问题是如果不同分区无法进行节点通信，那么可能会造成节点之间的数据是有差异的，所以 AP 类型的注册中心通过牺牲强一致性来保证高可用性 。 

对于 RPC 框架而言，即使注册中心出现问题，也不应该影响服务的正常调用，所以 AP 类型的注册中心在该场景下相比于 CP 类型的注册中心更有优势。 对于成熟的 RPC 框架而言，会提供多种注册中心的选择，接下来我们便设计一个通用的注册中心接口，然后每种注册中心的实现都按该接口规范行扩展。 

```java
public interface RegistryService {
    /**
     * 注册微服务
     *
     * @param serviceMetaData 服务元数据
     */
    void register(ServiceMetaData serviceMetaData) throws Exception;

    void unregister(ServiceMetaData serviceMetaData) throws Exception;

    ServiceMetaData discovery(String serviceName, int invokerHashCode) throws Exception;

    void destroy() throws IOException;
}
```

 RegistryService 接口包含注册中心四个基本操作：**服务注册 register**、**服务注销 unRegister**、**服务发现 discovery**、**注册中心销毁 destroy**。 

## 负载均衡算法

服务消费者在发起 RPC 调用之前，需要感知有多少服务端节点可用，然后从中选取一个进行调用。之前我们提到了几种常用的负载均衡策略：Round-Robin 轮询、Weighted Round-Robin 权重轮询、Least Connections 最少连接数、Consistent Hash 一致性 Hash 等。  一致性 Hash 算法可以保证每个服务节点分摊的流量尽可能均匀，而且能够把服务节点扩缩容带来的影响降到最低。下面我们一起看下一致性 Hash 算法的设计思路。 

在服务端节点扩缩容时，一致性 Hash 算法会尽可能保证客户端发起的 RPC 调用还是固定分配到相同的服务节点上。一致性 Hash 算法是采用**哈希环**来实现的，通过 Hash 函数将对象和服务器节点放置在哈希环上，一般来说服务器可以选择 IP + Port 进行 Hash。

关于一致性hash算法可参考： https://zhuanlan.zhihu.com/p/482549860?utm_medium=social&utm_oi=919687111576289280

负载均衡接口定义：

```java
public interface ServiceLoadBalancer<T> {
    T select(List<T> servers, int hashCode);
}
```

基于zk实现的一致性hash算法如下：

```java
public class ZKConsistentHashLoadBalancer implements ServiceLoadBalancer<ServiceInstance<ServiceMetaData>> {
    /**
     * 虚拟节点数，默认是10
     */
    private final static int VIRTUAL_NODE_SIZE = 10;

    private String buildServiceInstanceKey(ServiceInstance<ServiceMetaData> instance) {
        ServiceMetaData payload = instance.getPayload();
        return String.join(":", payload.getServiceAddr(), String.valueOf(payload.getPort()));
    }

    @Override
    public ServiceInstance<ServiceMetaData> select(List<ServiceInstance<ServiceMetaData>> servers, int hashCode) {
        TreeMap<Integer, ServiceInstance<ServiceMetaData>> ring = new TreeMap<>();
        for (ServiceInstance<ServiceMetaData> instance : servers) {
            for (int i = 0; i < VIRTUAL_NODE_SIZE; i++) {
                ring.put((buildServiceInstanceKey(instance) + VIRTUAL_NODE_SIZE + i).hashCode(), instance);
            }
        }

        // ceilingEntry() 方法找出大于或等于客户端 hashCode 的第一个节点，即为客户端对应要调用的服务节点
        Map.Entry<Integer, ServiceInstance<ServiceMetaData>> entry = ring.ceilingEntry(hashCode);
        if (entry == null) {
            entry = ring.firstEntry();
        }
        return entry.getValue();
    }
}

```





## 服务发现

服务发现的实现思路比较简单，首先找出被调用服务所有的节点列表，然后通过 ZKConsistentHashLoadBalancer 提供的一致性 Hash 算法找出相应的服务节点。具体代码实现如下： 

```java
 @Override
    public ServiceMetaData discovery(String serviceName, int invokerHashCode) throws Exception {
        Collection<ServiceInstance<ServiceMetaData>> serviceInstances = serviceDiscovery.queryForInstances(serviceName);

        // 通过一些负载均衡算法，选择一个服务实例
        ServiceInstance<ServiceMetaData> instance = new ZKConsistentHashLoadBalancer().select((List<ServiceInstance<ServiceMetaData>>) serviceInstances, invokerHashCode);
        if (instance == null) {
            return null;
        }
        return instance.getPayload();
    }
```