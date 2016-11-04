Introduce
---
This is a tool for transfering big data from local to many machines.   
It can speed up many times than before.  
Traditional method:  
    local -> a  
    local -> b  
    ...  
This project provides another method. A node will transfer to next at once when it recives from the previous:  
    local -> a -> b -> ...  

Prepare  
---
You should install command "netcat(nc)" in every machine.  

Usage  
---
chains.sh  configFile  data  

Config file format:  
---
ip        sshPort      sshUser     sshPassword  storeLocation  
127.0.0.1 22           root        123456       /root  

