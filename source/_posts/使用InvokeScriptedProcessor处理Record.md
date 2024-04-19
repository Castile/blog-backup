---
title: 使用InvokeScriptedProcessor处理Record
tags:
  - NiFi
categories:
  - NiFi
toc: true
date: 2024-03-18 00:43:38
---








##  InvokeScriptedProcessor模板(一个更快的ExecuteScript) 

原文地址：https://funnifi.blogspot.com/2017/06/invokescriptedprocessor-template-faster.html

 对于Apache Nifi中的快速，简单且小的脚本任务，ExecuteScript通常比InvokescriptedProcessor更好，因为很少有样板代码，关系和属性已经定义和支持，并且某些与Nifi API相关的对象（例如ProcessSession，ProcessContext和ComponentLog）已经被绑定到脚本引擎，作为脚本可以轻松使用的变量。 

 然而，一个权衡是性能;在ExecuteScript中，每次onTrigger被执行时，脚本都会被 evaluated  。对于InvokeScriptedProcessor，只要脚本(或任何InvokeScriptedProcessor属性)没有改变，脚本化的Processor实例就由处理器维护，当NiFi框架调用onTrigger()等父方法时，它的方法就会被简单地调用。 

 为了获得两者的最佳效果，我将InvokeScriptedProcessor实例放在一起，该实例的配置方式与ExecuteScript相同。提供了“成功”和“失败”的关系，API对象是可用的，如果您只是将您的ExecuteScript代码粘贴到下面脚本中的相同位置，它将表现得像一个性能更高的ExecuteScript实例。代码如下：

```groovy
////////////////////////////////////////////////////////////
// imports go here
////////////////////////////////////////////////////////////

class E{ void executeScript(session, context, log, REL_SUCCESS, REL_FAILURE) 
    {
        ////////////////////////////////////////////////////////////
        // your code goes here
        ////////////////////////////////////////////////////////////
    }
}

class GroovyProcessor implements Processor {
    def REL_SUCCESS = new Relationship.Builder().name("success").description('FlowFiles that were successfully processed are routed here').build()
    def REL_FAILURE = new Relationship.Builder().name("failure").description('FlowFiles that were not successfully processed are routed here').build()
    def ComponentLog log
    def e = new E()   
    void initialize(ProcessorInitializationContext context) { log = context.logger }
    Set<Relationship> getRelationships() { return [REL_FAILURE, REL_SUCCESS] as Set }
    Collection<ValidationResult> validate(ValidationContext context) { null }
    PropertyDescriptor getPropertyDescriptor(String name) { null }
    void onPropertyModified(PropertyDescriptor descriptor, String oldValue, String newValue) { }
    List<PropertyDescriptor> getPropertyDescriptors() { null }
    String getIdentifier() { null }    
    void onTrigger(ProcessContext context, ProcessSessionFactory sessionFactory) throws ProcessException {
        def session = sessionFactory.createSession()
        try {
            e.executeScript(session, context, log, REL_SUCCESS, REL_FAILURE)
            session.commit()
        } catch (final Throwable t) {
            log.error('{} failed to process due to {}; rolling back session', [this, t] as Object[])
            session.rollback(true)
            throw t
}}}
processor = new GroovyProcessor()
```



##  InvokeScriptedProcessor模板(使用Jython) 

 我在Groovy中提供了一个模板，该模板将允许NIFI用户将其ExecuteScript Groovy脚本移植到更快的InvokescriptedProcessor（ISP）处理器中。ISP比ExecuteScript更快，因为仅当代码或其他配置更改时才重新加载脚本，而executeScript每次调用处理器时都会评估脚本。 

 自从那篇文章以来，我已经收到了使用Jython编写的ISP模板的几个请求（例如此请求），因此使用Jython脚本执行的用户可以从ISP性能提升中受益。

```python
#////////////////////////////////////////////////////////////
#// imports go here
#////////////////////////////////////////////////////////////
from org.apache.nifi.processor import Processor,Relationship
from java.lang import Throwable

class E():
    def __init__(self):
        pass
    def executeScript(self,session, context, log, REL_SUCCESS, REL_FAILURE):
        log.warn("=====Hello========")
#end class

class JythonProcessor(Processor):   
    REL_SUCCESS = Relationship.Builder().name("success").description('FlowFiles that were successfully processed are routed here').build()
    REL_FAILURE = Relationship.Builder().name("failure").description('FlowFiles that were not successfully processed are routed here').build()
    log = None
    e = E()
    def initialize(self,context):
        self.log = context.logger
    def getRelationships(self):
        return set([self.REL_SUCCESS, self.REL_FAILURE])
    def validate(self,context):
        pass
    def onPropertyModified(self,descriptor, oldValue, newValue):
        pass
    def getPropertyDescriptors(self):
        return []
    def getIdentifier(self):
        return None    
    def onTrigger(self,context, sessionFactory):
        session = sessionFactory.createSession()
        try:
            self.e.executeScript(session, context, self.log, self.REL_SUCCESS, self.REL_FAILURE)
            session.commit()
        except Throwable, t:
            self.log.error('{} failed to process due to {}; rolling back session', [self, t])
            session.rollback(true)
            raise t
#end class

processor = JythonProcessor()
```





## 可复用的脚本

我们可以使用动态属性(在开发人员指南和之前的文章中有解释)，因为它们作为变量传递给ExecuteScript。然而，处理器的用户必须知道要添加和填充哪些属性，并且没有好的方法将这些信息传递给用户(至少使用ExecuteScript是这样)。 

但是，IndokescriptedProcessor可让您提供完整处理器实例的脚本实现。这意味着您可以定义自己的属性和关系，以及对它们的文档和验证。您的脚本可以提供功能，取决于处理器用户配置处理器的方式，而无需与脚本进行交互！ 

一个带有单个InvokescriptedProcessor（包含工作脚本）的模板可以拖到画布上，基本上就像将自定义处理器拖到画布上一样！当用户打开对话框时，他们会看到您添加的属性/关系，并且将像普通的属性一样（脚本语言，body等）进行验证。

脚本化的处理器只需要实现processor接口，该接口又扩展了AbstractConfigurableComponent。Groovy的基本框架是这样的:一个类包含一组被覆盖的接口方法

```groovy
class MyProcessor implements Processor {

    @Override
    void initialize(ProcessorInitializationContext context) { }

    @Override
    Set<Relationship> getRelationships() { return [] as Set }

    @Override
    void onTrigger(ProcessContext context, ProcessSessionFactory sessionFactory) throws ProcessException {
      // do stuff
    }

    @Override
    Collection<ValidationResult> validate(ValidationContext context) { return null }

    @Override
    PropertyDescriptor getPropertyDescriptor(String name) {
        return null
    }

    @Override
    void onPropertyModified(PropertyDescriptor descriptor, String oldValue, String newValue) { }

    @Override
    List<PropertyDescriptor> getPropertyDescriptors() { return [] as List }

    @Override
    String getIdentifier() { return 'MyProcessor-InvokeScriptedProcessor' }
}

processor = new MyProcessor()
```

请注意，类必须实现处理器并声明一个名为“Processor”的变量，该变量包含类的实例。这是InvokescriptedProcessor所要求的约定。

重要的是：尽管您可能会在NIFI代码中找到许多处理器扩展AbstractProcessor或AbstrackSessionFactoryProcessor，但是如果它扩展了这些类之一，则您的脚本很可能无法正常工作。这是由于这些类的validation() 方法被声明为最终，并且基本实现将期望一组受支持的属性描述符包括Invokescriptedprocessor（例如脚本文件），但仅使用列表来使用该列表您的脚本处理器提供。可能会有一个黑客解决这个问题，但即使可能，也不值得。

继续前进，假设我们要创建一个可重复使用的脚本处理器，该处理器工作于GenerateFlowFile，但允许用户提供流量文件的内容以及其“文件名”属性的值。此外，也许内容可以包括Nifi Expression语言（EL）构造，例如$ {hostName（）}。由于内容可能具有类似EL语句的内容，但是用户可能不希望对其进行评估，因此我们应该让用户决定是否在写入流文件之前评估EL语句的内容。最后，这是一个“生成”处理器，因此我们只需要“成功”关系。“失败”在这里没有真正的意义。话虽如此，捕获您的代码可以投掷的所有异常将很重要；在ProcessException并重新启动中包装每个，以便该框架可以正确处理。 

1. 添加“成功”关系并将其返回（在集合中）中的 getRealationships()
2. 添加一个“文件内容”属性以包含流量文件的预期内容（可能包括EL）
3. 添加一个“评估内容中的表达式”属性，以指示是否评估EL的内容
4. 添加一个可选的“文件名”属性，以覆盖默认的“文件名”属性。
5. 触发处理器时，创建一个流文件，写入内容（可能在评估EL之后），并可能设置文件名属性

下面是一个Groovy语言的代码示例：

```groovy
class GenerateFlowFileWithContent implements Processor {

    def REL_SUCCESS = new Relationship.Builder()
            .name('success')
            .description('The flow file with the specified content and/or filename was successfully transferred')
            .build();

    def CONTENT = new PropertyDescriptor.Builder()
            .name('File Content').description('The content for the generated flow file')
            .required(false).expressionLanguageSupported(true).addValidator(Validator.VALID).build()
    
    def CONTENT_HAS_EL = new PropertyDescriptor.Builder()
            .name('Evaluate Expressions in Content').description('Whether to evaluate NiFi Expression Language constructs within the content')
            .required(true).allowableValues('true','false').defaultValue('false').build()
            
    def FILENAME = new PropertyDescriptor.Builder()
            .name('Filename').description('The name of the flow file to be stored in the filename attribute')
            .required(false).expressionLanguageSupported(true).addValidator(StandardValidators.NON_EMPTY_VALIDATOR).build()
    
    @Override
    void initialize(ProcessorInitializationContext context) { }

    @Override
    Set<Relationship> getRelationships() { return [REL_SUCCESS] as Set }

    @Override
    void onTrigger(ProcessContext context, ProcessSessionFactory sessionFactory) throws ProcessException {
      try {
        def session = sessionFactory.createSession()
        def flowFile = session.create()
        
        def hasEL = context.getProperty(CONTENT_HAS_EL).asBoolean()
        def contentProp = context.getProperty(CONTENT)
        def content = (hasEL ? contentProp.evaluateAttributeExpressions().value : contentProp.value) ?: ''
        def filename = context.getProperty(FILENAME)?.evaluateAttributeExpressions()?.getValue()
        
        flowFile = session.write(flowFile, { outStream ->
                outStream.write(content.getBytes("UTF-8"))
            } as OutputStreamCallback)
        
        if(filename != null) { flowFile = session.putAttribute(flowFile, 'filename', filename) }
        // transfer
        session.transfer(flowFile, REL_SUCCESS)
        session.commit()
      } catch(e) {
          throw new ProcessException(e)
      }
    }

    @Override
    Collection<ValidationResult> validate(ValidationContext context) { return null }

    @Override
    PropertyDescriptor getPropertyDescriptor(String name) {
        switch(name) {
            case 'File Content': return CONTENT
            case 'Evaluate Expressions in Content': return CONTENT_HAS_EL
            case 'Filename': return FILENAME
            default: return null
        }
    }

    @Override
    void onPropertyModified(PropertyDescriptor descriptor, String oldValue, String newValue) { }

    @Override
    List<PropertyDescriptor>> getPropertyDescriptors() { return [CONTENT, CONTENT_HAS_EL, FILENAME] as List }

    @Override
    String getIdentifier() { return 'GenerateFlowFile-InvokeScriptedProcessor' }
    
}

processor = new GenerateFlowFileWithContent()
```

将其输入到InvokeScriptedProcessor的脚本主体中，语言设置为Groovy，然后应用(通过单击对话框上的Apply)，那么当重新打开对话框时，您应该看到关系设置为“success”，属性添加到配置对话框中。

此时，您可以将单个处理器保存为模板，称其为“生成FlowFileWithContent”之类的东西。现在，它是一个基本上可以作为处理器重复使用的模板。尝试将其拖到画布上并输入一些值，然后将其接线到其他处理器（例如Putfile）（查看它是否有效）：

希望这说明了InvokescriptedProcessor的功能和灵活性，以及如何使用自定义逻辑来创建可重复使用的处理器模板，而无需构建和部署NAR。









 最合适的方法可能是使用InvoKescriptedProcessor，因为您可以添加更复杂的属性（指定控制器服务，例如），而不是用户。 - 定义的executeScript属性。 

 话虽如此，对于任何基于记录的脚本处理器，您都需要大量的设置代码，并且在如何处理记录的情况下，有最佳练习，即您在创建RecordSetWriter之前处理第一个记录，以防万一您的自定义处理器代码需要更新RecordSetWriter将使用的架构。下面的 Groovy  示例改编自 [AbstractRecordProcessor](https://github.com/apache/nifi/blob/master/nifi-nar-bundles/nifi-standard-bundle/nifi-standard-processors/src/main/java/org/apache/nifi/processors/standard/AbstractRecordProcessor.java) ，这是标准NAR中所有记录处理器的共同基类。请注意，要处理第一个和其余记录的两个注释部分，这些是您将自定义代码处理记录的地方。最好是在脚本处理器中添加私有方法，然后将其调用一次以获取第一个记录，然后再次在循环中（这就是AbstractRecordProcessor所做的） 



```groovy
import org.apache.nifi.flowfile.attributes.CoreAttributes
import org.apache.nifi.processor.AbstractProcessor
import org.apache.nifi.processor.ProcessContext
import org.apache.nifi.processor.ProcessSession
import org.apache.nifi.processor.Relationship
import org.apache.nifi.processor.io.StreamCallback
import org.apache.nifi.serialization.*
import org.apache.nifi.serialization.record.*
import org.apache.nifi.schema.access.SchemaNotFoundException
import java.util.concurrent.atomic.AtomicInteger

class MyRecordProcessor extends AbstractProcessor {

    // Properties
    static final PropertyDescriptor RECORD_READER = new PropertyDescriptor.Builder()
        .name("record-reader")
        .displayName("Record Reader")
        .description("Specifies the Controller Service to use for reading incoming data")
        .identifiesControllerService(RecordReaderFactory.class)
        .required(true)
        .build()
    static final PropertyDescriptor RECORD_WRITER = new PropertyDescriptor.Builder()
        .name("record-writer")
        .displayName("Record Writer")
        .description("Specifies the Controller Service to use for writing out the records")
        .identifiesControllerService(RecordSetWriterFactory.class)
        .required(true)
        .build()

    def REL_SUCCESS = new Relationship.Builder().name("success").description('FlowFiles that were successfully processed are routed here').build()
    def REL_FAILURE = new Relationship.Builder().name("failure").description('FlowFiles are routed here if an error occurs during processing').build()

    @Override
    protected List<PropertyDescriptor> getSupportedPropertyDescriptors() {
        def properties = [] as ArrayList
        properties.add(RECORD_READER)
        properties.add(RECORD_WRITER)
        properties
    }

   @Override
    Set<Relationship> getRelationships() {
       [REL_SUCCESS, REL_FAILURE] as Set<Relationship>
    }

    @Override
    void onTrigger(ProcessContext context, ProcessSession session) {
        def flowFile = session.get()
        if (!flowFile) return

        def readerFactory = context.getProperty(RECORD_READER).asControllerService(RecordReaderFactory)
        def writerFactory = context.getProperty(RECORD_WRITER).asControllerService(RecordSetWriterFactory)
        
        final Map<String, String> attributes = new HashMap<>()
        final AtomicInteger recordCount = new AtomicInteger()
        final FlowFile original = flowFile
        final Map<String, String> originalAttributes = flowFile.attributes
        try {
            flowFile = session.write(flowFile,  { inStream, outStream ->
                    def reader = readerFactory.createRecordReader(originalAttributes, inStream, getLogger())
                     try {

                        // Get the first record and process it before we create the Record Writer. 
                        // We do this so that if the Processor updates the Record's schema, we can provide 
                        // an updated schema to the Record Writer. If there are no records, then we can
                        // simply create the Writer with the Reader's schema and begin & end the RecordSet
                        def firstRecord = reader.nextRecord()
                        if (!firstRecord) {
                            def writeSchema = writerFactory.getSchema(originalAttributes, reader.schema)
                            def writer = writerFactory.createWriter(getLogger(), writeSchema, outStream)
                            try {
                                writer.beginRecordSet()
                                def writeResult = writer.finishRecordSet()
                                attributes['record.count'] = String.valueOf(writeResult.recordCount)
                                attributes[CoreAttributes.MIME_TYPE.key()] = writer.mimeType
                                attributes.putAll(writeResult.attributes)
                                recordCount.set(writeResult.recordCount)
                            } finally {
                                writer.close()
                            }
                            return
                        }

                        /////////////////////////////////////////
                        // TODO process first record
                        /////////////////////////////////////////

                        def writeSchema = writerFactory.getSchema(originalAttributes, firstRecord.schema)
                        def writer = writerFactory.createWriter(getLogger(), writeSchema, outStream)
                        try {
                            writer.beginRecordSet()
                            writer.write(firstRecord)
                            def record
                            while (record = reader.nextRecord()) {
                                //////////////////////////////////////////
                                // TODO process next record
                                //////////////////////////////////////////
                                writer.write(processed)
                            }

                            def writeResult = writer.finishRecordSet()
                            attributes.put('record.count', String.valueOf(writeResult.recordCount))
                            attributes.put(CoreAttributes.MIME_TYPE.key(), writer.mimeType)
                            attributes.putAll(writeResult.attributes)
                            recordCount.set(writeResult.recordCount)
                        } finally {
                            writer.close()
                        }
                    } catch (final SchemaNotFoundException e) {
                        throw new ProcessException(e.localizedMessage, e)
                    } catch (final MalformedRecordException e) {
                        throw new ProcessException('Could not parse incoming data', e)
                    } finally {
                        reader.close()
                    }
                } as StreamCallback)
            
        } catch (final Exception e) {
            getLogger().error('Failed to process {}; will route to failure', [flowFile, e] as Object[])
            session.transfer(flowFile, REL_FAILURE);
            return;
        }
        flowFile = session.putAllAttributes(flowFile, attributes)
        recordCount.get() ?  session.transfer(flowFile, REL_SUCCESS) : session.remove(flowFile)
        def count = recordCount.get()
        session.adjustCounter('Records Processed', count, false)
        getLogger().info('Successfully converted {} records for {}', [count, flowFile] as Object[])
    }
}

processor = new MyRecordProcessor()
```

在session.write（）streamCallback内部，我们首先检查是否有任何记录，如果没有任何记录）并写出一个 zero-record 的flowfile。

在那之后，是时候与其他人分开处理第一个记录了。这是因为读者和/或自定义处理器代码可能会从读者的架构中更改作者的架构。例如，在架构推理期间，发生这种情况是自NIFI 1.9.0以来的读者的功能。

然后编写了第一个记录，其余记录的过程仍在继续。最后，填充了基于标准的记录的属性，然后更新流量文件并传输。上面的脚本还包括出现问题时的错误处理。