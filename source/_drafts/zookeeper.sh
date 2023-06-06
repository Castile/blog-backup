#!/bin/bash

case $1 in
	"start" ){
		for i in castile castile2 castile3; do
			#statements
			echo --------------zookeeper $i start ---------------
			ssh $i "/opt/zookeeper-3.5.7/bin/zkServer.sh start"
		done
		
	};;
	"stop" ){
		for i in castile castile2 castile3; do
			#statements
			echo --------------zookeeper $i stop ---------------
			ssh $i "/opt/zookeeper-3.5.7/bin/zkServer.sh stop"
		done
		
	};;
	"status" ){
		for i in castile castile2 castile3; do
			#statements
			echo --------------zookeeper $i status ---------------
			ssh $i "/opt/zookeeper-3.5.7/bin/zkServer.sh status"
		done
		
	};;
esac