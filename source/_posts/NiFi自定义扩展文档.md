---
title: NiFi自定义扩展文档
tags:
  - NiFi
  - 文档
categories:
  - NiFi
toc: true
date: 2024-02-24 18:02:16
---




#  一、 NiFi组件 

NiFi提供了几个扩展点，使开发人员能够向应用程序添加功能以满足他们的需求。下面的列表提供了最常见扩展点的高级描述

##  1. Processor 

处理器接口是NiFi公开对FlowFiles、其属性和内容的访问的机制。处理器是用于组成NiFi数据流的基本元素。该接口用于完成以下所有任务 

- 创建FlowFiles
- 读取FlowFile内容
- 写FlowFile内容
- 读FlowFile属性
- 更新FlowFile属性
- 摄取数据
- 输出数据
- 路由数据
- 提取数据
- 修改数据 

##  2. ReportingTask 

 ReportingTask接口允许将指标、监控信息和内部NiFi状态发布到外部端点，如日志文件、电子邮件和远程web服务。 

## 3. ParameterProvider

ParameterProvider接口允许外部源提供参数。提供的参数仍然存储在参数上下文中，但是这种机制允许在外部提供和管理它们。 

## 4.  ControllerService 

 在单个JVM中，ControllerService提供跨处理器、其他ControllerServices、参数提供者和reportingtask的共享状态和功能。一个示例用例可能包括将非常大的数据集加载到内存中。通过在ControllerService中执行这项工作，数据可以加载一次，并通过该服务向所有处理器公开，而不是要求许多不同的处理器自己加载数据集。 

## 5.  FlowFilePrioritizer 

FlowFilePrioritizer接口提供了一种机制，通过该机制可以对队列中的FlowFiles进行优先级排序或排序，以便FlowFiles可以按照最有效的顺序处理特定用例。 

## 6.  AuthorityProvider 

 AuthorityProvider负责确定应该授予给定用户哪些特权和角色(如果有的话) 



# 二、 Processor API

处理器是NiFi中使用最广泛的组件。处理器是唯一被赋予创建、删除、修改或检查FlowFiles(数据和属性)权限的组件。所有的处理器都是使用Java的ServiceLoader机制加载和实例化的。

虽然Processor是一个可以直接实现的接口，但是这样做是非常罕见的，因为org.apache.nifi.processor.AbstractProcessor是几乎所有Processor实现的基类。 AbstractProcessor类提供了大量的功能，这使得开发Processor的任务变得更加容易和方便。在本文的范围内，我们将主要关注处理Processor API时的AbstractProcessor类。 

>  NiFi是一个高度并发的框架。这意味着所有扩展都必须是线程安全的。如果不熟悉用Java编写并发软件，强烈建议您熟悉Java并发原则。 

为了理解Processor API，我们必须首先理解几个支持类和接口。 



## FlowFile

 FlowFile是一个逻辑概念，它将一段数据与一组关于该数据的属性相关联。这些属性包括FlowFile的唯一标识符，以及它的名称、大小和任何其他特定于流的值。虽然FlowFile的内容和属性可以改变，但FlowFile对象是不可变的。对FlowFile的修改可以通过ProcessSession实现。 

FlowFiles的核心属性定义在org.apache.nifi.flowfile.attributes.CoreAttributes enum中。

-  Filename (filename): FlowFile的文件名。文件名不应包含任何目录结构 
-  UUID (uuid):分配给该FlowFile的通用唯一标识符，用于将该FlowFile与系统中的其他FlowFile区分开来。 
-  路径(path): FlowFile的路径是指FlowFile所属的相对目录，不包含文件名。 
- 绝对路径( absolute.path ): FlowFile的绝对路径是指FlowFile所属的绝对目录，不包含文件名。 
-  优先级( priority ):表示FlowFile优先级的数值。 
-  MIME Type ( mime.type ):这个流文件的MIME类型。 
-  丢弃原因( discard.reason ):指定FlowFile被丢弃的原因。  
- 替代标识符( alternate.identifier ):指示FlowFile的UUID之外的标识符，已知该标识符引用该FlowFile。 

**其他的公共属性：**

 虽然这些属性不是CoreAttributes枚举的成员，但它们实际上是整个系统的标准，并且可以在大多数FlowFiles中找到。 

- 文件大小(fileSize): FlowFile内容的大小，单位为字节。
-  输入日期(entryDate): FlowFile进入系统(即创建)的日期和时间。此属性的值是一个数字，表示从1970年1月1日午夜(UTC)开始的毫秒数。 
-  血统开始日期(lineageStartDate):任何时候，一个FlowFile被克隆，合并，或者分割，这将导致一个“子”FlowFile被创建。当这些子代被克隆、合并或分裂时，一个祖先链就建立起来了。该值表示最早的祖先进入系统的日期和时间。考虑这个问题的另一种方式是，该属性表示FlowFile通过系统的延迟。取值为数字，表示从1970年1月1日午夜(UTC)开始的毫秒数。 



## ProcessSession

ProcessSession(通常简称为“会话”)提供了一种机制，通过该机制可以创建、销毁、检查、克隆FlowFiles，并将其传输到其他处理器。此外，ProcessSession提供了通过添加或删除属性或修改FlowFile的内容来创建修改版本的FlowFiles的机制。ProcessSession还公开了一种发出**出处事件（  [Provenance Events](https://nifi.apache.org/docs/nifi-docs/html/developer-guide.html#provenance_events) ）**的机制，该机制提供了跟踪FlowFile沿袭和历史的能力。 在对一个或多个FlowFiles执行操作后，ProcessSession可以提交或回滚。 



## ProcessContext

ProcessContext提供了处理器和框架之间的桥梁。它提供有关处理器当前如何配置的信息，并允许处理器执行特定于框架的任务， 比如释放自己的资源，这样框架就可以在不消耗不必要资源的情况下调度其他处理器运行。 

## PropertyDescriptor

PropertyDescriptor定义了一个属性，该属性将被Processor、ReportingTask、ParameterProvider或ControllerService使用。属性的定义包括其名称、属性描述、可选的默认值、验证逻辑和指示说明是否需要该属性才能使Processor有效。PropertyDescriptor是通过实例化PropertyDescriptor的实例来创建的。构造器类，调用适当的方法来填充有关属性的详细信息，最后调用构建方法。 

## Validator

属性描述符必须指定一个或多个验证器，用于确保用户输入的属性值是有效的。如果Validator指示属性值无效，则在该属性变为有效之前，组件将无法运行或使用。如果没有指定Validator，组件将被认为是无效的，NiFi将报告不支持该属性。

## ValidationContext

当验证属性值时，ValidationContext可以用来获取ControllerServices，创建PropertyValue对象，并使用表达式语言编译和计算属性值。



## PropertyValue

返回给Processor的所有属性值都以PropertyValue对象的形式返回。该对象具有将值从String转换为其他形式(如数字和时间段)的方便方法，并提供用于求值Expression Language的API。 



## Relationship

关系定义了FlowFile可以从处理器传输到的路由。通过实例化Relationship的实例来 `Relationship.Builder`  ，调用适当的方法来填充关系的详细信息，最后调用构建方法。 



## StateManager

 StateManager为处理器、报告任务和控制器服务提供了一种容易存储和检索状态的机制， 该API类似于ConcurrentHashMap，但每个操作都需要一个Scope。 这个Scope表示这个state是存在本地还是集群维度的。



## ProcessorInitializationContext

在创建了一个Processor之后，它的initialize方法将被InitializationContext对象调用。该对象向处理器公开在整个处理器生命周期中不会改变的配置，例如处理器的唯一标识符。 

## ComponentLog

建议处理器通过ComponentLog接口执行日志记录，而不是获取第三方日志记录器的直接实例。这是因为通过ComponentLog进行日志记录允许框架将超过可配置严重性级别的日志消息呈现给用户界面，从而允许在发生重要事件时通知监视数据流的人员。此外，它通过在DEBUG模式下记录堆栈跟踪并在日志消息中提供处理器的唯一标识符，为所有处理器提供一致的日志记录格式。 



# 三、AbstractProcessor API

由于绝大多数处理器将通过扩展AbstractProcessor来创建，因此我们将在本节中研究抽象类。AbstractProcessor提供了几个处理器开发人员会感兴趣的方法。 

## 1、 处理器初始化

 在创建Processor之后，在调用任何其他方法之前，将调用AbstractProcessor的init方法。 该方法接受一个参数，类型为ProcessorInitializationContext。 上下文对象向处理器提供一个ComponentLog、处理器的唯一标识符和一个 ControllerServiceLookup  (可用于与已配置的ControllerServices交互)。这些对象中的每一个都由AbstractProcessor存储，并且可以由子类分别通过getLogger、getIdentifier和getControllerservicellookup方法获得。

## 2、 暴露处理器属性 

大多数处理器在使用之前都需要一定数量的用户配置。  处理器支持的属性通过getSupportedPropertyDescriptors方法公开给框架。 此方法不接受任何参数，并返回PropertyDescriptor对象的列表。**列表中对象的顺序很重要，因为它决定了属性在用户界面中呈现的顺序。** 

###  动态处理器属性 

 除了标准属性之外，有时还希望允许用户配置名称不是预定义的其他属性。  这可以通过覆盖getSupportedDynamicPropertyDescriptor方法来实现。  此方法接受String作为其唯一参数，该参数指示属性的名称。该方法返回一个PropertyDescriptor对象，该对象可用于验证属性的名称和值。  从这个方法返回的任何PropertyDescriptor都应该在PropertyDescriptor中设置isDynamic的值为true。。AbstractProcessor的默认行为是不允许任何动态创建的属性。

###  敏感动态属性 

动态属性的默认实现不将属性值视为敏感值。在配置FlowFile属性或自定义表达式等特性时，这种方法是足够的，但它不能为密码或密钥等值提供保护。  

NiFi 1.17.0通过一个名为SupportsSensitiveDynamicProperties的注解引入了对敏感动态属性的框架支持。注释可以通过getSupportedDynamicPropertyDescriptor方法应用于支持动态属性的处理器、控制器服务或报告任务。注释表明组件允许将单个动态属性标记为敏感属性，以用于持久化和框架处理。 

 getSupportedDynamicPropertyDescriptor必须返回一个 `sensitive`  设置为false的PropertyDescriptor，以允许自定义敏感状态。在此方法中将敏感字段设置为true将强制将所有动态属性作为敏感属性处理。这种方法允许在受支持的组件中升级敏感状态，但不降级。 

敏感属性值的安全处理是带注释的类的责任。支**持敏感动态属性的组件不能记录属性值或将属性值作为FlowFile属性提供。** 

## 3、 验证处理器属性

如果处理器的配置无效，则处理器无法启动。 

处理器属性的验证可以通过在PropertyDescriptor上设置Validator或通过PropertyDescriptor限制属性的允许值来实现。Builder的allowableValues方法或identifiesControllerService方法。  此外，如果一个属性依赖于另一个属性( `PropertyDescriptor.Builder’s `dependsOn` method ），切不满足的话则会被校验住。

```java
PropertyDescriptor USE_FILE = new PropertyDescriptor.Buildler()
    .name("Use File")
    .displayName("Use File")
    .required(true)
    .allowableValues("true", "false")
    .defaultValue("true")
    .build();
```

或者

```java
PropertyDescriptor FILE = new PropertyDescriptor.Builder()
    .name("File to Use")
    .displayName("File to Use")
    .required(true)
    .addValidator(StandardValidators.FILE_EXISTS_VALIDATOR)
    .dependsOn(USE_FILE, "true")
    .build();
```



有时单独验证一个Processor的属性是不够的。为此，AbstractProcessor公开了一个customValidate方法。该方法接受ValidationContext类型的单个参数。这个方法的返回值是一个ValidationResult对象的集合，它描述了在验证过程中发现的任何问题。只有那些isValid方法返回false的ValidationResult对象才应该被返回。 只有当所有属性根据其关联的验证器和允许值都有效时，才会调用此方法。也就是说，只有当所有属性本身都有效时，这个方法才会被调用，并且这个方法允许将处理器的配置作为一个整体进行验证。 

##  4、响应配置中的更改 

 有时，当处理器的属性发生变化时，我们希望它立即做出反应。  onPropertyModified方法允许处理器这样做。当用户更改处理器的属性值时，将为每个修改的属性调用onPropertyModified方法。 

 该方法接受三个参数:PropertyDescriptor(表示修改了哪个属性、旧值和新值。  如果属性之前没有值，第二个参数将为空。  如果该属性被删除，则第三个参数将为空。重要的是要注意，无论值是否有效，都会调用此方法。这个方法将只在值被实际修改时调用，而不是在用户更新处理器而不更改其值时调用。在调用此方法时，可以保证调用此方法的线程是当前在处理器中执行代码的唯一线程，除非处理器本身创建了自己的线程。 



## 5、 执行工作

 当处理器有工作要做时，它通过框架调用它的onTrigger方法来进行调度。 

 该方法有两个参数:一个ProcessContext和一个ProcessSession。onTrigger方法的第一步通常是通过调用ProcessSession上的get方法来获取要在其上执行工作的FlowFile。 

 对于从外部源摄取数据到NiFi的处理器，跳过此步骤。然后处理器可以自由地检查FlowFile属性;添加、删除或修改属性;读取或修改FlowFile内容;并将FlowFiles传输到适当的关系。 

## 6、  处理器何时被触发 

处理器的onTrigger方法只有在计划运行时才会被调用，并且处理器有工作要做。如果满足以下任何一个条件，就称处理器存在工作

-  目标是处理器的连接在其队列中至少有一个FlowFile 
-  处理器没有传入连接
-  处理器用@TriggerWhenEmpty注释 

有几个因素会影响处理器的onTrigger方法何时被调用。

首先，除非用户已将Processor配置为运行，否则不会触发Processor。如果处理器被安排运行，框架会定期(周期由用户在用户界面中配置)检查处理器是否有工作要做。如果是，框架将检查处理器的下游目的地。 

 **如果处理器的任何出站连接已满，默认情况下，处理器将不会被安排运行。** 

 但是，@TriggerWhenAnyDestinationAvailable注释可以添加到Processor的类中。  在这种情况下，需求被更改为只有一个下游目的地必须是“可用的”(如果Connection队列未满，则认为目的地是“可用的”)，而不是要求所有下游目的地都可用。 

与处理器调度相关的还有 @TriggerSerially 注释。使用此注释的处理器永远不会有多个线程同时运行onTrigger方法。但是，需要注意的是，执行代码的线程在调用之间可能会发生变化。因此，仍然必须小心确保处理器是线程安全的



##  7、组件生命周期 

### @OnAdded

 @OnAdded注释会在创建组件时立即调用一个方法 ， `initialize`  方法将在组件构造之后被调用，然后是带有@OnAdded注释的方法。 该方法在组件的生命周期中只会被调用一次。带有此注释的方法必须不带参数。 

### @OnEnabled

 @OnEnabled注释可以用来指示一个方法应该在控制器服务被启用时被调用。 任何具有此注释的方法都会在每次用户启用该服务时被调用。此外，每次重启NiFi时，如果将NiFi配置为“ auto-resume state ”并且启用了服务，则将调用该方法。

如果带有此注释的方法抛出Throwable，则将为该组件发出一条日志消息和公告。在这种情况下，服务将保持在“ ENABLING ”状态，并且将不可用。带有此注释的所有方法将在延迟后再次调用。在所有带有此注释的方法都返回而不抛出任何东西之前，该服务将无法使用。 

### @OnRemoved

 @OnRemoved注释导致在组件从流中移除之前调用一个方法。这允许在删除组件之前清理资源。带有此注释的方法必须不带参数。**如果带有此注释的方法抛出异常，该组件仍将被删除。** 

### @OnScheduled

 每次计划运行组件时都应调用该方法。因为ControllerServices没有被调度，所以在ControllerService上使用这个注释是没有意义的。 它应该仅用于处理器和 Reporting Tasks 。如果具有此注释的任何方法抛出Exception，则不会调用具有此注释的其他方法，并将向用户显示通知。 

 在这种情况下，然后触发带有@OnUnscheduled注释的方法，然后触发带有@OnStopped注释的方法(在此状态下，如果这些方法中的任何一个抛出异常，这些异常将被忽略)。  然后，该组件将在一段时间内执行，这段时间称为“Administrative yield Duration”，这是在nifi中配置的一个值。 最后，进程将再次启动，直到所有带@OnScheduled注释的方法都返回而不抛出任何异常。 

带有此注释的方法可以不带参数，也可以只带一个参数。如果使用单个参数变体，如果组件是Processor，则参数必须是ProcessContext类型，如果组件是ReportingTask，则参数必须是ConfigurationContext类型。 



### @OnUnscheduled

每当处理器或ReportingTask不再调度运行时，将调用带有此注释的方法。此时，在Processor的onTrigger方法中可能仍有许多线程处于活动状态。如果这样的方法抛出异常，将生成一条日志消息，否则将忽略该异常，并且仍将调用带有此注释的其他方法。带有此注释的方法可以不带参数，也可以只带一个参数。如果使用单个参数变体，如果组件是Processor或ConfigurationContext，则参数必须是ProcessContext类型 

### @OnStopped

 当处理器或ReportingTask不再调度运行并且所有线程都从onTrigger方法返回时，将调用带有此注释的方法。如果这样的方法抛出异常，将生成一条日志消息，否则该异常将被忽略;使用此注释的其他方法仍将被调用。带有此注释的方法允许接受0或1个参数。如果使用了参数，如果组件是ReportingTask，则参数的类型必须是ConfigurationContext;如果组件是Processor，则参数的类型必须是ProcessContext。 

### @OnShutdown

任何带有@OnShutdown注释的方法都将在NiFi成功关闭时被调用。如果这样的方法抛出异常，将生成一条日志消息，否则将忽略该异常，并且仍将调用带有此注释的其他方法。带有此注释的方法**必须不带参数**。注意:虽然NiFi将尝试在使用它的所有组件上调用带有此注释的方法，但这并不总是可能的。 

例如，进程可能意外终止，在这种情况下，它没有机会调用这些方法。因此，虽然使用此注释的方法可用于清理资源，但不应依赖于关键业务逻辑。 

## 8、组件通知

### @OnPrimaryNodeStateChange

 @OnPrimaryNodeStateChange注释会在集群中主节点的状态发生变化时立即调用方法。带有此注释的方法要么不带参数，要么只带一个PrimaryNodeState类型的参数。PrimaryNodeState提供有关更改内容的上下文，以便组件可以采取适当的操作。PrimaryNodeState枚举器有两种可能的值:ELECTED PRIMARY NODE(接收此状态的节点已被选为NiFi集群的主节点)或PRIMARY NODE REVOKED( 接收此状态的节点是主节点，但现在其主节点角色已被撤销)



## 9.、约束组件

受限制的组件是可用于执行操作员通过NIFI REST API/UI提供的任意不固定的代码，或者可以使用NIFI OS凭据在NIFI主机系统上获取或更改数据。 

这些组件可以被授权的NiFi用户用于超出应用程序的预期用途，升级特权，或者可能暴露有关NiFi进程或主机系统内部的数据。所有这些功能都应该被认为是特权的，管理员应该知道这些功能，并为一部分受信任的用户显式地启用它们。 

处理器、控制器服务或报告任务可以使用@Restricted注释进行标记。这将导致组件被视为受限组件，并且需要将用户显式地添加到可以访问受限组件的用户列表中。一旦用户被允许访问受限制的组件，他们将被允许创建和修改这些组件，假设所有其他权限都被允许。如果不能访问受限制的组件，用户仍然会知道这些类型的组件的存在，但即使有其他足够的条件，也无法创建或修改它们。



## 10、状态管理

从ProcessContext、ReportingContext和ControllerServiceInitializationContext中，组件可以调用getStateManager()方法。这个状态管理器负责提供一个简单的API来存储和检索状态。  该机制旨在使开发人员能够轻松地存储一组密钥/值对，检索这些值并原子更新它们。该状态可以在群集中局部存储在节点上，也可以在所有节点中存储。 

然而，需要注意的是，该机制的目的只是提供一种存储非常“简单”状态的机制。  因此，API只允许存储和检索Map<String, String>，并自动替换整个Map。此外，目前唯一支持存储集群范围状态的实现是由ZooKeeper支持的。  因此，在序列化之后，整个State Map的大小必须小于1mb。试图存储超过此值将导致抛出异常。如果处理器管理状态所需的交互比这更复杂(例如，必须存储和检索大量数据，或者必须单独存储和获取单个键)，则应该使用不同的机制(例如，与外部数据库通信)。 

### Scope

当与状态管理器通信时，所有方法调用都需要提供Scope。这个Scope将是Scope.LOCAL或Scope.CLUSTER。如果NiFi在集群中运行，则此Scope向框架提供有关操作应该如何发生的重要信息。 

 如果状态使用 Scope.CLUSTER 存储。集群中的所有节点都将使用相同的状态存储机制进行通信。如果使用 Scope.LOCAL ，那么每个节点将看到状态的不同表示。 

还值得注意的是，如果将NiFi配置为作为独立实例运行，而不是在集群中运行，则 Scope总是使用Scope.LOCAL。这样做是为了允许NiFi组件的开发人员以一种一致的方式编写代码，而不必担心NiFi实例是否集群。相反，开发人员应该假设实例是集群的，并相应地编写代码。 



## 11. 报告处理器的活动

 处理器负责报告其活动，以便用户能够了解其数据发生了什么。处理器应通过ComponentLog记录事件，该事件可通过初始化访问或调用AbstractProcessor的GetLogger方法访问。 

此外，处理器应使用通过ProcessSession的 `getProvenanceReporter`  方法获得的 `ProvenanceReporter`  接口。  ProvenanceReporter应该用于指示从外部源接收内容或将内容发送到外部位置的任何时间。  ProvenanceReTorter还具有报告何时克隆，分叉或修改的流文件以及将多个流文件合并到单个流纸上以及将流纸与其他一些标识符关联的方法。  但是，这些功能不太重要，因为该框架能够检测到这些内容并代表处理器发出适当的事件。 

 然而，对于处理器开发人员来说，发出这些事件是最佳实践，因为它在代码中变得明确说明这些事件正在发出，并且开发人员能够为事件提供其他细节，例如该动作采取了有关所采取的措施的信息。  如果处理器发出事件，则该框架将不会发出重复的事件。相反，它总是假设处理器开发人员比框架更了解处理器上下文中发生的事情。 

但是，框架可能会发出另一个事件。例如，如果处理器对FlowFile的内容及其属性进行修改，然后仅发射 ATTRIBUTES_MODIFIED  事件，则该框架将发出 CONTENT_MODIFIED  事件。 













