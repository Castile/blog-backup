# 使用ScriptedTransformRecord更改记录字段名称 

经常出现的一个问题是“我如何更改所有记录字段名称？”有些人想对所有字段名称进行大小写转换，有些人想将其标准化（以删除/替换目标系统无效的字符），等等。 

 这里描述了一些解决方案，但它们是手动的，这意味着您必须知道所有字段的名称。如果能够基于某些规则(例如大写、替换)以编程方式更改字段名称，将会很有帮助。我们可以为此使用ScriptedTransformRecord处理器 。

 下面是一个大写所有字段名的Groovy脚本，但是我在该部分添加了一个注释，该注释将完成创建新字段名的工作，该部分可以用计算所需字段名的任何代码替换。

```groovy
import org.apache.nifi.serialization.*
import org.apache.nifi.serialization.record.*
import org.apache.nifi.serialization.record.util.*
def recordSchema = record.schema
def recordFields = recordSchema.fields
def derivedFields = [] as List<RecordField>
def derivedValues = [:] as Map<String, Object>
recordFields.each {recordField -> 
    def originalFieldName = recordField.fieldName

    // Manipulate the field name(s) here
    def newFieldName = originalFieldName.toUpperCase()

    // Add the new RecordField, to be used in creating a new schema
    derivedFields.add(new RecordField(
		newFieldName,
		recordField.dataType,
		recordField.defaultValue,
		recordField.aliases,
		recordField.nullable))

    // Add the original value to the new map using the new field name as the key
    derivedValues.put(newFieldName, record.getValue(recordField))
}
def derivedSchema = new SimpleRecordSchema(derivedFields)
return new MapRecord(derivedSchema, derivedValues)
```

 该脚本遍历原始RecordSchema中的RecordFields，然后填充一个新的RecordFields列表(在名称更新之后)以及字段名称到原始值的映射。然后创建一个新的模式，并用于创建一个从脚本返回的新记录。

