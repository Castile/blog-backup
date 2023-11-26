---
title: 无状态的NiFi
tags:
  - NiFi
  - Stateless
categories:
  - NiFi
toc: true
date: 2023-11-26 15:35:13
---


## 介绍

Apache NiFi应用程序可以被认为是两个独立但相互交织的组件:流作者组件和流引擎。通过将这两个组件集成到一个应用程序中，NiFi允许用户创建数据流并在同一个用户界面中实时运行它。

然而，这两个概念是可以分开的。NiFi可以用来创建流，然后不仅可以由NiFi运行，还可以由其他兼容的数据流引擎运行。Apache NiFi项目提供了几个这样的数据流引擎:Apache NiFi本身、MiNiFi Java (Apache NiFi的一个子项目)、MiNiFi c++ (Apache NiFi的一个子项目)和无状态NiFi

这些数据流引擎中的每一个都有自己的优点和缺点，因此它们有自己最擅长解决的特定用例。本文将介绍无状态NiFi是什么，如何使用它，以及它的优点和缺点

## 传统的NiFi

NiFi被设计为作为大型多租户应用程序运行。它努力充分利用提供给它的所有资源，包括磁盘/存储和许多线程。通常，单个NiFi实例跨许多不同的节点集群，形成一个大型的内聚数据流，该数据流可能由许多不同的子流组成。一般来说，NiFi将承担交付给它的数据的所有权。它将数据可靠地存储在磁盘上，直到它被传递到所有必要的目的地。此数据的交付可以在流中的不同位置进行优先级排序，以便将对特定目的地最重要的数据首先交付到该目的地，而相同的数据可以根据优先级以不同的顺序交付到另一个目的地。NiFi在完成所有这些工作的同时，保持非常细粒度的沿袭，并保持流中每个组件所看到的数据缓冲区(数据沿袭和数据滚动缓冲区的组合称为data Provenance)。

这些特性中的每一个都非常重要，可以提供一个非常强大、广泛、全面的视图，了解数据是如何在企业上操作和流经企业的。然而，在一些用例中，更轻量级的应用程序可以更好地服务于这些用例。一个能够与NiFi可以交互的所有不同端点进行交互的应用程序，并执行NiFi可以执行的所有转换、路由、过滤和处理。但是一个应用程序被设计为只运行一个小的子流，而不是一个有许多源和汇的大数据流。

## 无状态NiFi

进入无状态NiFi(在本文档中也简称为“无状态”)。无状态NiFi中的许多概念与典型的Apache NiFi引擎中的概念不同。

无状态提供了一个占用空间更小的数据流引擎。它不包括用于编写或监视数据流的用户界面，而是运行使用NiFi应用程序编写的数据流。NiFi在能够访问快速存储(如SSD和NVMe驱动器)时表现最佳，而Stateless则将所有数据存储在内存中。

这意味着如果无状态NiFi停止，它将不再能够直接访问正在运行的数据。因此，无状态应该只用于数据源可靠且可重放的数据流，或者数据丢失不是关键问题的场景。

一个非常常见的用例是让无状态NiFi从Apache Kafka或JMS读取数据，然后执行一些路由/过滤/操作，最后将数据传递到另一个目的地。如果像这样的数据流要在NiFi中运行，那么数据将从源被消耗，写入NiFi的内部存储库，并得到确认，因此NiFi将获得该数据的所有权。然后，它将负责将其传递到所有目的地，即使应用程序重新启动也是如此。

但是，使用无状态NiFi，数据将被使用，然后传输到流中的下一个处理器。数据不会被写入任何类型的内部存储库，也不会被确认。流中的下一个处理器将处理数据，然后将其传递下去。只有当数据到达整个数据流的末端时，才会确认从源接收到的数据。如果在处理完成之前重新启动Stateless，则数据尚未得到确认，因此只是再次使用它。这允许在内存中处理数据，而不必担心数据丢失，但它也让源承担了可靠地存储数据并使数据可重放的责任。



## 可兼容的数据流

如上所述，无状态NiFi要求数据源既可靠又可重放。这限制了无状态可以合理交互的源。此外，对于无状态引擎能够运行的数据流，还有一些其他限制。

### 1、 单一来源、单一目标

在无状态状态下运行的每个数据流应该保持在单个源和单个接收器或目的地。由于Stateless不存储它正在处理的数据，也不存储元数据，例如数据流中数据排队的位置，因此将单个FlowFile发送到多个目的地可能导致数据重复。

考虑一个流，其中数据从Apache Kafka消费，然后交付到HDFS和S3。如果数据存储在HDFS中，然后存储到S3失败，则整个会话将被回滚，并且必须再次使用数据。因此，数据可能会被第二次消费并交付给HDFS。如果这种情况继续发生，数据将继续从Kafka提取并存储在HDFS中。根据目的地和流配置，这可能不是一个问题(除了浪费资源之外)，但在许多情况下，这是一个重要的问题。

因此，如果要使用无状态引擎运行数据流，那么应该将这样的数据流分解为两个不同的数据流。第一个将数据从Apache Kafka传送到HDFS，另一个将数据从Apache Kafka传送到S3。每个数据流都应该为Kafka使用一个单独的Consumer Group，这将导致每个数据流获得相同数据的副本

### 2、对合并的支持可能有限

由于无状态NiFi中的数据从头到尾同步地通过数据流传输，因此使用需要多个flowfile(如MergeContent和MergeRecord)的处理器可能无法接收成功所需的所有数据。如果处理器有数据排队并被触发，但没有取得任何进展，则无状态引擎将再次触发源处理器，以便向处理器提供额外的数据

然而，这可能导致数据不断被引入的情况，这取决于处理器的行为。为了避免这种情况，可以通过配置限制可能带入数据流的单个调用的数据量。如果数据流配置将每次调用的数据量限制为10 MB，但是配置了MergeContent直到至少有100 MB的可用数据才创建bin，则数据流将继续触发MergeContent运行，而不进行任何进展，直到达到最大bin年龄(如果配置)或数据流超时。

此外，根据运行Stateless的上下文，触发源组件可能不会提供额外的数据。例如，如果在数据在输入端口中排队，然后触发数据流的环境中运行无状态，则随后触发输入端口运行将不会产生额外的数据

因此，确保任何包含合并FlowFiles逻辑的数据流都配置了MergeContent和MergeRecord的最大Bin Age是很重要的。

### 3、故障处理

在传统的NiFi中，将从给定处理器的“失败”连接循环回同一处理器是很常见的。这导致处理器不断尝试处理FlowFile，直到它成功为止。这可能非常重要，因为通常一个NiFi接收数据，它负责获得该数据的所有权，并且必须能够保存该数据，直到下游服务能够接收它并随后交付该数据。

然而，对于无状态NiFi，假定数据源既可靠又可重放。此外，根据设计，无状态NiFi在重启后不会保存数据。因此，对故障处理的考虑可能会有所不同。使用无状态NiFi，如果无法将数据传递到下游系统，通常最好将FlowFile路由到输出端口，然后将输出端口标记为故障端口(参见下面的[失败端口](#failure- Ports)了解更多信息)。

### 4、流不应该加载大量文件

在传统的NiFi中，FlowFile内容存储在磁盘上，而不是内存中。因此，它能够处理任何大小的数据，只要它适合磁盘。然而，在无状态中，FlowFile内容存储在内存中，在JVM堆中。因此，通常不建议尝试将大量文件(例如100 GB数据集)加载到无状态NiFi中。这样做通常会导致OutOfMemoryError，或者至少会导致大量垃圾收集，从而降低性能。



## 特性对比

如上所述，无状态NiFi提供了一组不同于传统NiFi的特性和权衡。在这里，我们总结一下关键的区别。这种比较并不详尽，但可以快速了解这两个运行时是如何运行的。
| Feature | Traditional NiFi | Stateless NiFi |
|---------|------------------|----------------|
| 数据持久性 | 数据可靠地存储在磁盘上的FlowFile和Content Repositories中 | 数据存储在内存中，必须在重新启动时再次从源端使用 |
| 数据排序 | 数据在每个连接中根据选择的优先级排序独立排序 | 数据按照接收到的顺序在系统中流动(先进先出/ FIFO) |
| Site-to-Site | 支持完整的Site-to-Site功能，包括服务器和客户端角色 | 可以向NiFi实例推送或从NiFi实例拉取，但不能接收传入的站点到站点连接。也就是说，作为客户端而不是服务器工作 |
| Form Factor | 旨在利用多个内核和磁盘的优势 | 轻巧的外形因素。很容易嵌入到另一个应用程序。单线程处理 |
| Heap Considerations | 通常，许多用户正在使用许多处理器。不应该将FlowFile内容加载到堆中，因为它很容易导致堆耗尽 | 较小的数据流使用较少的堆。Flow一次只对一个或几个FlowFile进行操作，并将FlowFile的内容保存在Java堆的内存中。 |
| Data Provenance | 完全存储、索引的数据来源，可以通过UI浏览并通过Reporting Tasks导出 | 有限的数据来源功能，事件存储在内存中。无法查看，但可以使用Reporting Tasks导出。但是，由于它们在内存中，因此它们将在重新启动时丢失，并且可能在导出之前滚出 |
| 嵌入性 | 虽然在技术上可以嵌入传统的NiFi，但不建议这样做，因为它会启动一个重量级的用户界面，处理复杂的身份验证和授权，以及几个基于文件的外部依赖项，这可能很难管理 | 具有最小的外部依赖关系(包含扩展的目录和用于临时存储的工作目录)，并且更易于管理。可嵌入性是无状态NiFi的一个重要特性。 |