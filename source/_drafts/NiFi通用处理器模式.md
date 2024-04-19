---
title: NiFi通用处理器模式
tags:
categories:
---



#  数据导入 

将数据摄取到NiFi中的处理器有一个名为success的关系。该处理器通过ProcessSession创建方法生成新的FlowFiles，并且不会从传入的连接中提取FlowFiles。Processor名称以“Get”或“Listen”开头，这取决于它是轮询外部源还是公开外部源可以连接的某些接口。名称以用于通信的协议结尾。遵循此模式的处理器包括GetFile、getftp、ListenHTTP和GetHTTP。 

此处理器可以在使用@OnScheduled注释的方法中创建或初始化连接池。  但是，由于通信问题可能会阻止连接建立或导致连接终止，因此此时不会创建连接本身。相反，连接是在onTrigger方法中从池中创建或租用的。 

 如果可能的话，此处理器的onTrigger方法首先从连接池租用连接，或者以其他方式创建到外部服务的连接。  当没有来自外部源的可用数据时，ProcessContext的yield方法由处理器调用，该方法返回，这样处理器就可以避免持续运行和消耗资源。 否则，这个处理器通过ProcessSession的create方法创建一个FlowFile，并为FlowFile分配一个合适的文件名和路径(通过添加文件名和路径属性)，以及任何其他可能合适的属性。  通过ProcessSession的write方法获得FlowFile内容的OutputStream，传递一个新的OutputStreamCallback(通常是一个匿名的内部类)。在这个回调中，处理器能够写入FlowFile，并将来自外部资源的内容流到FlowFile的OutputStream。如果希望将InputStream的整个内容写入FlowFile, ProcessSession的importFrom方法可能比write方法更方便使用。

当此处理器期望接收许多小文件时，建议在提交会话之前从单个会话创建几个FlowFiles，这允许框架更有效地处理新创建的FlowFiles的内容。 

此处理器生成一个出处事件，表明它已接收到数据并指定数据来自何处。该处理器应该记录FlowFile的创建，以便在必要时通过分析日志来确定FlowFile的来源。 

该处理器确认收到数据和/或从外部来源中删除数据，以防止收到重复的文件，这只有在创建FlowFile的ProcessSession提交之后才会完成， 不遵守此原则可能会导致数据丢失，因为在会话提交之前重新启动NiFi将导致临时文件被删除。 但是请注意，使用这种方法接收重复数据是可能的，因为在提交会话之后，在确认或从外部源删除数据之前，应用程序可能会重新启动。 但是，一般来说，潜在的数据重复比潜在的数据丢失更受重视。连接最终被返回或添加到连接池中，这取决于连接是从连接池中租用的还是在onTrigger方法中创建的。

 如果存在通信问题，连接通常会被终止，而不会返回(或添加)到连接池。断开与远程系统的连接，并在带有@OnStopped注释的方法中关闭连接池，以便可以回收资源。 



# 数据出口

向外部源发布数据的处理器有两种关系:成功和失败。处理器名称以“Put”开头，后面跟着用于数据传输的协议。遵循此模式的处理器包括PutEmail、PutSFTP和PostHTTP(注意名称不以“Put”开头，因为这会导致混淆，因为在处理HTTP时，Put和POST具有特殊含义)。 

此处理器可以在使用@OnScheduled注释的方法中创建或初始化连接池。但是，由于通信问题可能会阻止连接建立或导致连接终止，因此此时不会创建连接本身。相反，连接是在onTrigger方法中从池中创建或租用的。

onTrigger方法首先通过get方法从ProcessSession获取一个FlowFile。如果没有FlowFile可用，则该方法返回而不获取到远程资源的连接。 

如果至少有一个FlowFile可用，处理器从连接池中获取一个连接，如果可能的话，或者创建一个新的连接。如果处理器既不能从连接池租用连接，也不能创建新连接，则FlowFile被路由到失败，记录事件，并返回方法。

如果获得了连接，处理器通过调用ProcessSession上的read方法并传递InputStreamCallback(通常是一个匿名的内部类)来获得FlowFile内容的InputStream，并从该回调中将FlowFile的内容传输到目的地。  该事件连同传输文件所花费的时间和传输文件的数据速率一起被记录下来。通过getProvenanceReporter方法从ProcessSession获取报告器并调用报告器上的SEND方法，将SEND事件报告给ProvenanceReporter。返回连接或将连接添加到连接池中，具体取决于连接是从池中租用的还是由onTrigger方法新创建的。 

如果存在通信问题，连接通常会被终止，而不会返回(或添加)到连接池。  如果在向远程资源发送数据时出现问题，则处理错误的理想方**//*-/




















 




 





