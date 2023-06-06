---
title: 'Centos7防火墙问题:Unit iptables.service could not be found.'
tags:
  - linux
  - centos
categories:
  - Problems
toc: true
date: 2021-08-05 00:17:41
---


# Centos7防火墙问题:Unit iptables.service could not be found.



# 问题

在搭建zookeeper集群的时候出错，查看防火墙状态发现：

```shell
[root@castile zookeeper-3.5.7]# service iptables status
Redirecting to /bin/systemctl status iptables.service
Unit iptables.service could not be found.

```

![1628093509711](centos防火墙问题/1628093509711.png)



# 解决

1. 安装iptables-services

   ```shell
    yum install iptables-services
   ```

   ![1628093561277](centos防火墙问题/1628093561277.png)

   ![1628093584574](centos防火墙问题/1628093584574.png)

2.  启动iptables 并查看状态

   ![1628093708413](centos防火墙问题/1628093708413.png)



其他：

service iptables stop ： 关闭防火墙

chkconfig iptables off