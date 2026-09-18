#!/bin/bash

#Author:Pankaj Kumar
echo $(date)

echo "UPTIME AND LOAD:" 
uptime 

echo "DISK USAGE:"
df -h 

echo "MEMORY USAGE:"
free -m 

echo "CPU USAGE:"
top

echo "NETWORK STATUS:"
ip a

echo "DISK I/O:"
iotop

