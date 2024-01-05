# hdfs-cluster-deploy

Automatically deploy Hadoop (HDFS) HA Cluster solution based on Zookeeper


| App       | Download Url                                                                                                                  |
|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| OpenJDK8  | https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u392b08.tar.gz  |
| Zookeeper | https://archive.apache.org/dist/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz                                   |
| Hadoop    | https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz                                                |


Download the hadoop tar package to the file directory in the local role.

```bash
wget -O roles/specific_roles/install_hadoop/files/hadoop-3.3.6.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```
