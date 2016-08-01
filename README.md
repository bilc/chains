+ This is a tool for transfering bing data from local to many machines.   
Traditional method:  
    local -> a  
    local -> b  
    ...  
This project provides another method:  
    local -> a -> b -> ...  

+ Prepare  
    You should install command "netcat(nc)" in every machine.  

+ Usage  
>    chains.sh  configFile  data  

+ config file format:  
ip        sshPort      sshUser     sshPassword  storeLocation  
>    127.0.0.1 22           root        123456       /root  

