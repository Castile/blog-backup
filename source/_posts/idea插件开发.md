---
title: idea插件开发首次体验
tags:
  - plugin
  - 插件
date: 2020-07-22 10:17:06
---


# 创建工程

![1595382541790](idea插件开发\1595382541790.png)

创建的是一个插件工程，使用idea的SDK。

创建之后在目录下有一个文件

![1595382858947](idea插件开发\1595382858947.png)

```xml
<idea-plugin>
<!--  插件的id-->
  <id>com.hongliang.first.id</id>
<!--  插件名称-->
  <name>first Plugin</name>
<!--  版本号-->
  <version>1.0</version>
<!--  作者和提供方的信息-->
  <vendor email="zhl396740445@163.com" url="http://hongliangzhu.cn">Castile</vendor>

<!--  插件的描述-->
  <description><![CDATA[
      Enter short description for your ss plugin here.<br>
      <em>most HTML tags  may be used</em>
    ]]></description>

<!-- 变更日志  -->
  <change-notes><![CDATA[
      Add change notes  here.<br>
      <em>most HTML tags  may be used</em>
    ]]>
  </change-notes>


<!--  插件支持的版本号-->
  <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/build_number_ranges.html for description -->
  <idea-version since-build="173.0"/>

  <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/plugin_compatibility.html
       on how to target different products -->
  <!-- uncomment to enable plugin in all products
  <depends>com.intellij.modules.lang</depends>
  -->
<!--  相关的其他依赖-->
  <depends>com.intellij.modules.lang</depends>

<!--  扩展内容-->
  <extensions defaultExtensionNs="com.intellij">
    <!-- Add your extensions here -->
  </extensions>

<!--  菜单动作 -->
  <actions>

    <action id="firstPluginActionID" class="com.hongliang.first.firstPluginAction" text="测试" description="测试描述">
      <add-to-group group-id="ToolsMenu" anchor="first"/>
      <keyboard-shortcut keymap="$default" first-keystroke="ctrl I"/>
    </action>
  </actions>

</idea-plugin>
```

# 创建一个Action

![1595382945490](idea插件开发\1595382945490.png)

我们创建一个在ToolsMenu的插件，在tools工具栏里面有一个“测试”的插件，点击之后在idea的右下角显示一个通知。

![1595383085436](idea插件开发\1595383085436.png)

```java
package com.hongliang.first;

import com.intellij.notification.Notification;
import com.intellij.notification.NotificationDisplayType;
import com.intellij.notification.NotificationGroup;
import com.intellij.notification.Notifications;
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.ui.MessageType;

/**
 * @author Hongliang Zhu
 * @create 2020-07-22 8:40
 */
public class firstPluginAction extends AnAction {

    @Override
    public void actionPerformed(AnActionEvent e) {
        // TODO: insert action logic here
        NotificationGroup notificationGroup = new NotificationGroup("我的第一个插件", NotificationDisplayType.BALLOON, true);
        Notification notification = notificationGroup.createNotification("点击测试", MessageType.INFO);
        Notifications.Bus.notify(notification);
    }
}

```

点击运行，与普通的java类运行一样，但是插件运行的话会打开一个新的idea

![1595383208023](idea插件开发\1595383208023.png)

可以看见在Tools工具栏里面有一个“测试”的插件，点击之后可以看到在右下角出现了一个通知

![1595383328138](idea插件开发\1595383328138.png)



到此，一个简单的插件入门程序就完成了，接下来我们对插件进行打包。



# 打包发布



![1595383719746](idea插件开发\1595383719746.png)

可以发现在项目目录下生成了一个jar包。

![1595383773902](idea插件开发\1595383773902.png)

# 安装

Files->plugin

![1595383905095](idea插件开发\1595383905095.png)

![1595384007268](idea插件开发\1595384007268.png)

然后重启idea

![1595384082604](idea插件开发\1595384082604.png)



大功告成。但是，这只是初步涉猎，任重而道远。