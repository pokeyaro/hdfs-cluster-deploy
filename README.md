# hdfs-cluster-deploy

Automatically deploy Hadoop (HDFS) HA Cluster solution based on Zookeeper

## Prerequisites

| App       | Download Url                                                                                                                  |
|-----------|-------------------------------------------------------------------------------------------------------------------------------|
| OpenJDK8  | https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u392b08.tar.gz  |
| Zookeeper | https://archive.apache.org/dist/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz                                   |
| Hadoop    | https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz                                                |

Download the hadoop tar package to the file directory in the local role.

```bash
wget -O roles/specific_roles/install_hadoop/files/hadoop-3.3.6.tar.gz https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

First, a clean Debian 11 distribution OS serves as the foundation for the environment.

```bash
root@localhost:~# cat /etc/hostname
localhost

root@localhost:~# cat /etc/hosts
127.0.0.1        localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

root@localhost:~# ll /home
total 0
drwxr-xr-x 3 admin admin 90 Nov 28  2022 admin

root@localhost:~# uname -r
5.19.0-0.deb11.2-amd64

root@localhost:~# cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

## Using Ansible Roles for Task Deployment

### Automated Deployment of a ZooKeeper Cluster

1. Writing the Inventory Host List File

```bash
root@ansible-server:/etc/ansible# cat << EOF > inventories/hosts_stage_zk
[zookeeper]
10.2.102.205 hostname=zookeeper01 alias=zk-node1
10.2.102.206 hostname=zookeeper02 alias=zk-node2
10.2.102.207 hostname=zookeeper03 alias=zk-node3
EOF
```

2. Viewing the encrypted variable file in Vault

```bash
# You can use Ansible Vault to create or edit sensitive data that needs to be encrypted as required.
# 1. ansible-vault create <encrypted_file>
# 2. ansible-vault edit <encrypted_file>
root@ansible-server:/etc/ansible# ansible-vault view secrets/secrets_stage.yml
Vault password: ********
# inventory information
ansible_ssh_user: root
ansible_ssh_port: 22
ansible_ssh_pass: 'root'

# role information
zk_password: 'Zookeeper@12345'
```

3. Executing an Ansible Playbook Role

```bash
# The command execution is roughly as follows:
ansible-playbook \
-i ${inventory_file} \
-e "target_hosts=${inventory_group}" \
-e "vault_file=${vault_file}" \
--ask-vault-pass \
${playbook_file}

# Task List Based on Roles:
# 1. Set OS system environment baseline.
# 2. Configure passwordless SSH authentication between nodes.
# 3. Create Zookeeper user group.
# 4. Install OpenJDK dependency.
# 5. Install Zookeeper and configure the cluster.
root@ansible-server:/etc/ansible# tree roles/
roles/
├── general_roles
│   ├── create_user_group
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── vars
│   │       └── main.yml
│   ├── os_basic_setup
│   │   ├── files
│   │   │   ├── aliyun-mirror.list
│   │   │   └── hosts
│   │   └── tasks
│   │       └── main.yml
│   └── setup_ssh_keys
│       ├── tasks
│       │   └── main.yml
│       └── vars
│           └── main.yml
└── specific_roles
├── install_java
│   ├── tasks
│   │   └── main.yml
│   └── vars
│       └── main.yml
└── install_zk
├── tasks
│   └── main.yml
├── templates
│   └── zoo.cfg.j2
└── vars
└── main.yml
```

4. We have wrapped the playbook into main.sh

```bash
root@ansible-server:/etc/ansible# sh main.sh

PLAY [Playbook running Ansible version 2.10.8] **************************************************************

TASK [Gathering Facts] **************************************************************************************
ok: [10.2.102.205]
ok: [10.2.102.207]
ok: [10.2.102.206]

TASK [os_basic_setup : Copy the Aliyun mirror list to source list directory] ********************************
changed: [10.2.102.207]
changed: [10.2.102.206]
changed: [10.2.102.205]

TASK [os_basic_setup : Clean the local apt repository and update the package lists from the repositories] ***
changed: [10.2.102.205]changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [os_basic_setup : Set system hostname] *****************************************************************
changed: [10.2.102.206]
changed: [10.2.102.205]
changed: [10.2.102.207]

TASK [os_basic_setup : Copy user profiles files to /etc/skel for new user default setup] ********************
changed: [10.2.102.206] => (item=.bashrc)
changed: [10.2.102.205] => (item=.bashrc)
changed: [10.2.102.207] => (item=.bashrc)
changed: [10.2.102.205] => (item=.profile)
changed: [10.2.102.206] => (item=.profile)
changed: [10.2.102.207] => (item=.profile)
changed: [10.2.102.206] => (item=.vimrc)
changed: [10.2.102.205] => (item=.vimrc)
changed: [10.2.102.207] => (item=.vimrc)

TASK [os_basic_setup : Overwrite /etc/hosts file with customized one] ***************************************
changed: [10.2.102.206]
ok: [10.2.102.205]
ok: [10.2.102.207]

TASK [os_basic_setup : Add defined hosts to /etc/hosts file] ************************************************
changed: [10.2.102.206] => (item=10.2.102.205)
changed: [10.2.102.205] => (item=10.2.102.205)
changed: [10.2.102.207] => (item=10.2.102.205)
changed: [10.2.102.207] => (item=10.2.102.206)
changed: [10.2.102.205] => (item=10.2.102.206)
changed: [10.2.102.206] => (item=10.2.102.206)
changed: [10.2.102.207] => (item=10.2.102.207)
changed: [10.2.102.205] => (item=10.2.102.207)
changed: [10.2.102.206] => (item=10.2.102.207)

TASK [setup_ssh_keys : Get current user] ********************************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [setup_ssh_keys : Get user's home directory] ***********************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [setup_ssh_keys : Set some path fact for non-root users] ***********************************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [setup_ssh_keys : Generate new SSH key pair on remote server] ******************************************
changed: [10.2.102.205]
changed: [10.2.102.207]
changed: [10.2.102.206]

TASK [setup_ssh_keys : Retrieve newly generated public key from remote server] ******************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [setup_ssh_keys : Concatenate all retrieved public keys on local machine] ******************************
changed: [10.2.102.205]

TASK [setup_ssh_keys : Check if authorized_keys file exists on remote server] *******************************
ok: [10.2.102.207]
ok: [10.2.102.205]
ok: [10.2.102.206]

TASK [setup_ssh_keys : Create authorized_keys file on remote server if it doesn't exist] ********************
skipping: [10.2.102.205]
skipping: [10.2.102.206]
skipping: [10.2.102.207]

TASK [setup_ssh_keys : Add public keys to authorized_keys file on remote server] ****************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [setup_ssh_keys : Remove temporary public key files on local machine] **********************************
changed: [10.2.102.205]

TASK [create_user_group : Ensure mkpasswd utility is installed on localhost] ********************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [create_user_group : Generate SHA-512 password hash for the new user] **********************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [create_user_group : Create a new group for the user] **************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [create_user_group : Create a new group for the user] **************************************************
changed: [10.2.102.207]
changed: [10.2.102.205]
changed: [10.2.102.206]

TASK [create_user_group : Ensure the Ansible temp directory for the user exists] ****************************
changed: [10.2.102.206]
changed: [10.2.102.205]
changed: [10.2.102.207]

TASK [install_java : Retrieve filename from the OpenJDK URL] ************************************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_java : Download OpenJDK tarball from specified URL] *******************************************
changed: [10.2.102.207]
changed: [10.2.102.205]
changed: [10.2.102.206]

TASK [install_java : Extract the directory name from the downloaded OpenJDK tarball] ************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_java : Create directory for OpenJDK installation] *********************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_java : Uncompress the OpenJDK tarball to the desired directory] *******************************
changed: [10.2.102.206]
changed: [10.2.102.205]
changed: [10.2.102.207]

TASK [install_java : Delete downloaded OpenJDK tarball] *****************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_java : Add JAVA environment variables to /etc/profile] ****************************************
changed: [10.2.102.205] => (item= )
changed: [10.2.102.206] => (item= )
changed: [10.2.102.207] => (item= )
changed: [10.2.102.205] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.206] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.207] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.205] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.206] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.207] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.205] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.206] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.207] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.205] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.206] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.207] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.205] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.206] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.207] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.205] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.206] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.207] => (item=# END ANSIBLE JAVA BLOCK)
ok: [10.2.102.205] => (item= )
ok: [10.2.102.206] => (item= )
ok: [10.2.102.207] => (item= )

TASK [install_zk : Extract tarball filename from URL] *******************************************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_zk : Download Zookeeper tarball from URL] *****************************************************
changed: [10.2.102.206]
changed: [10.2.102.205]
changed: [10.2.102.207]

TASK [install_zk : Extract directory name from downloaded tarball] ******************************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_zk : Set facts for Zookeeper directories and config file] *************************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_zk : Create Zookeeper base directory] *********************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Uncompress Zookeeper tarball to the base directory] **************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Create Zookeeper data directories and set permissions] ***********************************
changed: [10.2.102.205] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data)
changed: [10.2.102.206] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data)
changed: [10.2.102.207] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data)
changed: [10.2.102.205] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data_log)
changed: [10.2.102.206] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data_log)
changed: [10.2.102.207] => (item=/opt/zk/apache-zookeeper-3.9.1-bin/data_log)

TASK [install_zk : Generate and upload Zookeeper configuration file] ****************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Set appropriate permissions for Zookeeper configuration file] ****************************
ok: [10.2.102.205]
ok: [10.2.102.206]
ok: [10.2.102.207]

TASK [install_zk : Create and write node identifier to 'myid' file] *****************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Cleanup downloaded Zookeeper tarball] ****************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Update ~/.bashrc to include ZOOKEEPER environment variables] *****************************
changed: [10.2.102.205]
changed: [10.2.102.207]
changed: [10.2.102.206]

TASK [install_zk : Start the Zookeeper service] *************************************************************
changed: [10.2.102.205]
changed: [10.2.102.206]
changed: [10.2.102.207]

TASK [install_zk : Verify Zookeeper service status] *********************************************************
changed: [10.2.102.205]
changed: [10.2.102.207]
changed: [10.2.102.206]

TASK [install_zk : Print out Zookeeper service status] ******************************************************
ok: [10.2.102.205] => {
    "zk_status_output.stdout_lines": [
        "Client port found: 2181. Client address: localhost. Client SSL: false.",
        "Mode: follower"
    ]
}
ok: [10.2.102.206] => {
    "zk_status_output.stdout_lines": [
        "Client port found: 2181. Client address: localhost. Client SSL: false.",
        "Mode: follower"
    ]
}
ok: [10.2.102.207] => {
    "zk_status_output.stdout_lines": [
        "Client port found: 2181. Client address: localhost. Client SSL: false.",
        "Mode: leader"
    ]
}

TASK [Prompt information] ***********************************************************************************
ok: [10.2.102.205] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.206] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.207] => {
    "msg": "All tasks of ansible roles have been completed ~"
}

PLAY RECAP **************************************************************************************************
10.2.102.205               : ok=44   changed=30   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
10.2.102.206               : ok=42   changed=29   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
10.2.102.207               : ok=42   changed=28   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

5. As we can see, the second-to-last task checked the status of ZooKeeper on each node. We can also access each node to view it

```bash
# host list
➜ ~ hosts=("10.2.102.205" "10.2.102.206" "10.2.102.207")

# Iterating through the host list using a loop
➜ ~ for host in "${hosts[@]}"
do
echo "################################"
echo "Executing: $host"
ssh root@$host "hostname; su - zookeeper -c 'zkServer.sh status'"
done
################################
Executing: 10.2.102.205
zookeeper01
ZooKeeper JMX enabled by default
Using config: /opt/zk/apache-zookeeper-3.9.1-bin/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
################################
Executing: 10.2.102.206
zookeeper02
ZooKeeper JMX enabled by default
Using config: /opt/zk/apache-zookeeper-3.9.1-bin/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: follower
################################
Executing: 10.2.102.207
zookeeper03
ZooKeeper JMX enabled by default
Using config: /opt/zk/apache-zookeeper-3.9.1-bin/bin/../conf/zoo.cfg
Client port found: 2181. Client address: localhost. Client SSL: false.
Mode: leader
```

### Automated Deployment of an HDFS cluster

1. Similarly, automating the deployment using Ansible:

```bash
root@ansible-server:/etc/ansible# cat inventories/hosts_stage
[hdfs:children]
namenode
datanode

[namenode:children]
nn_master
nn_standby

[nn_master]
10.2.102.208 hostname=namenode01 alias=hdfs-master

[nn_standby]
10.2.102.209 hostname=namenode02 alias=hdfs-slave1
10.2.102.210 hostname=namenode03 alias=hdfs-slave2

[datanode]
10.2.102.211 hostname=datanade01 alias=hdfs-data1
10.2.102.212 hostname=datanode02 alias=hdfs-data2
10.2.102.213 hostname=datanode03 alias=hdfs-data3
10.2.102.214 hostname=datanode04 alias=hdfs-data4
10.2.102.215 hostname=datanode05 alias=hdfs-data5
```

2. The process of task deployment is as follows:

```bash
root@ansible-server:/etc/ansible# sh main.sh

PLAY [Playbook running Ansible version 2.10.8] ************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************
ok: [10.2.102.215]
ok: [10.2.102.213]
ok: [10.2.102.212]
ok: [10.2.102.211]
ok: [10.2.102.214]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [os_basic_setup : Copy the Aliyun mirror list to source list directory] ******************************************************************
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.211]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [os_basic_setup : Clean the local apt repository and update the package lists from the repositories] *************************************
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.210]
changed: [10.2.102.209]

TASK [os_basic_setup : Set system hostname] ***************************************************************************************************
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.211]
changed: [10.2.102.208]
changed: [10.2.102.210]
changed: [10.2.102.209]

TASK [os_basic_setup : Copy user profiles files to /etc/skel for new user default setup] ******************************************************
changed: [10.2.102.211] => (item=.bashrc)
changed: [10.2.102.212] => (item=.bashrc)
changed: [10.2.102.213] => (item=.bashrc)
changed: [10.2.102.214] => (item=.bashrc)
changed: [10.2.102.215] => (item=.bashrc)
changed: [10.2.102.211] => (item=.profile)
changed: [10.2.102.213] => (item=.profile)
changed: [10.2.102.212] => (item=.profile)
changed: [10.2.102.215] => (item=.profile)
changed: [10.2.102.214] => (item=.profile)
changed: [10.2.102.211] => (item=.vimrc)
changed: [10.2.102.213] => (item=.vimrc)
changed: [10.2.102.215] => (item=.vimrc)
changed: [10.2.102.214] => (item=.vimrc)
changed: [10.2.102.212] => (item=.vimrc)
changed: [10.2.102.208] => (item=.bashrc)
changed: [10.2.102.210] => (item=.bashrc)
changed: [10.2.102.209] => (item=.bashrc)
changed: [10.2.102.210] => (item=.profile)
changed: [10.2.102.208] => (item=.profile)
changed: [10.2.102.209] => (item=.profile)
changed: [10.2.102.210] => (item=.vimrc)
changed: [10.2.102.208] => (item=.vimrc)
changed: [10.2.102.209] => (item=.vimrc)

TASK [os_basic_setup : Overwrite /etc/hosts file with customized one] *************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [os_basic_setup : Add defined hosts to /etc/hosts file] **********************************************************************************
changed: [10.2.102.214] => (item=10.2.102.211)
changed: [10.2.102.211] => (item=10.2.102.211)
changed: [10.2.102.213] => (item=10.2.102.211)
changed: [10.2.102.215] => (item=10.2.102.211)
changed: [10.2.102.212] => (item=10.2.102.211)
changed: [10.2.102.211] => (item=10.2.102.212)
changed: [10.2.102.214] => (item=10.2.102.212)
changed: [10.2.102.213] => (item=10.2.102.212)
changed: [10.2.102.215] => (item=10.2.102.212)
changed: [10.2.102.212] => (item=10.2.102.212)
changed: [10.2.102.211] => (item=10.2.102.213)
changed: [10.2.102.213] => (item=10.2.102.213)
changed: [10.2.102.212] => (item=10.2.102.213)
changed: [10.2.102.214] => (item=10.2.102.213)
changed: [10.2.102.215] => (item=10.2.102.213)
changed: [10.2.102.211] => (item=10.2.102.214)
changed: [10.2.102.213] => (item=10.2.102.214)
changed: [10.2.102.212] => (item=10.2.102.214)
changed: [10.2.102.214] => (item=10.2.102.214)
changed: [10.2.102.215] => (item=10.2.102.214)
changed: [10.2.102.211] => (item=10.2.102.215)
changed: [10.2.102.213] => (item=10.2.102.215)
changed: [10.2.102.212] => (item=10.2.102.215)
changed: [10.2.102.214] => (item=10.2.102.215)
changed: [10.2.102.215] => (item=10.2.102.215)
changed: [10.2.102.211] => (item=10.2.102.208)
changed: [10.2.102.213] => (item=10.2.102.208)
changed: [10.2.102.212] => (item=10.2.102.208)
changed: [10.2.102.214] => (item=10.2.102.208)
changed: [10.2.102.215] => (item=10.2.102.208)
changed: [10.2.102.211] => (item=10.2.102.209)
changed: [10.2.102.213] => (item=10.2.102.209)
changed: [10.2.102.212] => (item=10.2.102.209)
changed: [10.2.102.214] => (item=10.2.102.209)
changed: [10.2.102.215] => (item=10.2.102.209)
changed: [10.2.102.211] => (item=10.2.102.210)
changed: [10.2.102.214] => (item=10.2.102.210)
changed: [10.2.102.212] => (item=10.2.102.210)
changed: [10.2.102.213] => (item=10.2.102.210)
changed: [10.2.102.215] => (item=10.2.102.210)
changed: [10.2.102.208] => (item=10.2.102.211)
changed: [10.2.102.209] => (item=10.2.102.211)
changed: [10.2.102.210] => (item=10.2.102.211)
changed: [10.2.102.208] => (item=10.2.102.212)
changed: [10.2.102.210] => (item=10.2.102.212)
changed: [10.2.102.209] => (item=10.2.102.212)
changed: [10.2.102.208] => (item=10.2.102.213)
changed: [10.2.102.210] => (item=10.2.102.213)
changed: [10.2.102.209] => (item=10.2.102.213)
changed: [10.2.102.208] => (item=10.2.102.214)
changed: [10.2.102.210] => (item=10.2.102.214)
changed: [10.2.102.209] => (item=10.2.102.214)
changed: [10.2.102.208] => (item=10.2.102.215)
changed: [10.2.102.210] => (item=10.2.102.215)
changed: [10.2.102.209] => (item=10.2.102.215)
changed: [10.2.102.208] => (item=10.2.102.208)
changed: [10.2.102.210] => (item=10.2.102.208)
changed: [10.2.102.209] => (item=10.2.102.208)
changed: [10.2.102.208] => (item=10.2.102.209)
changed: [10.2.102.210] => (item=10.2.102.209)
changed: [10.2.102.209] => (item=10.2.102.209)
changed: [10.2.102.208] => (item=10.2.102.210)
changed: [10.2.102.210] => (item=10.2.102.210)
changed: [10.2.102.209] => (item=10.2.102.210)

TASK [create_user_group : Ensure mkpasswd utility is installed on localhost] ******************************************************************
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [create_user_group : Generate SHA-512 password hash for the new user] ********************************************************************
ok: [10.2.102.213]
ok: [10.2.102.212]
ok: [10.2.102.215]
ok: [10.2.102.214]
ok: [10.2.102.211]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [create_user_group : Create a new group for the user] ************************************************************************************
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.211]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [create_user_group : Create a new group for the user] ************************************************************************************
changed: [10.2.102.212]
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [create_user_group : Ensure the Ansible temp directory for the user exists] **************************************************************
changed: [10.2.102.212]
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Get current user] ******************************************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Get user's home directory] *********************************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Set some path fact for non-root users] *********************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [setup_ssh_keys : Generate new SSH key pair on remote server] ****************************************************************************
changed: [10.2.102.213]
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.215]
changed: [10.2.102.209]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Retrieve newly generated public key from remote server] ****************************************************************
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.214]
changed: [10.2.102.211]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Concatenate all retrieved public keys on local machine] ****************************************************************
changed: [10.2.102.211]

TASK [setup_ssh_keys : Check if authorized_keys file exists on remote server] *****************************************************************
ok: [10.2.102.213]
ok: [10.2.102.212]
ok: [10.2.102.215]
ok: [10.2.102.211]
ok: [10.2.102.214]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [setup_ssh_keys : Create authorized_keys file on remote server if it doesn't exist] ******************************************************
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Add public keys to authorized_keys file on remote server] **************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [setup_ssh_keys : Remove temporary public key files on local machine] ********************************************************************
changed: [10.2.102.211]

TASK [install_java : Retrieve filename from the OpenJDK URL] **********************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_java : Download OpenJDK tarball from specified URL] *****************************************************************************
changed: [10.2.102.214]
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.215]
changed: [10.2.102.209]
changed: [10.2.102.208]
changed: [10.2.102.210]

TASK [install_java : Extract the directory name from the downloaded OpenJDK tarball] **********************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.213]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_java : Create directory for OpenJDK installation] *******************************************************************************
changed: [10.2.102.212]
changed: [10.2.102.211]
changed: [10.2.102.214]
changed: [10.2.102.213]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_java : Uncompress the OpenJDK tarball to the desired directory] *****************************************************************
changed: [10.2.102.212]
changed: [10.2.102.214]
changed: [10.2.102.211]
changed: [10.2.102.215]
changed: [10.2.102.213]
changed: [10.2.102.208]
changed: [10.2.102.210]
changed: [10.2.102.209]

TASK [install_java : Delete downloaded OpenJDK tarball] ***************************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_java : Add JAVA environment variables to /etc/profile] **************************************************************************
changed: [10.2.102.211] => (item= )
changed: [10.2.102.212] => (item= )
changed: [10.2.102.213] => (item= )
changed: [10.2.102.214] => (item= )
changed: [10.2.102.215] => (item= )
changed: [10.2.102.211] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.212] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.214] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.213] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.215] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.211] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.212] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.214] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.215] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.213] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.211] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.212] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.214] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.215] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.213] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.211] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.212] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.215] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.214] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.213] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.211] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.212] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.214] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.215] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.213] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.211] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.212] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.214] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.215] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.213] => (item=# END ANSIBLE JAVA BLOCK)
ok: [10.2.102.211] => (item= )
ok: [10.2.102.212] => (item= )
ok: [10.2.102.214] => (item= )
ok: [10.2.102.215] => (item= )
ok: [10.2.102.213] => (item= )
changed: [10.2.102.208] => (item= )
changed: [10.2.102.209] => (item= )
changed: [10.2.102.210] => (item= )
changed: [10.2.102.208] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.209] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.210] => (item=# BEGIN ANSIBLE JAVA BLOCK)
changed: [10.2.102.208] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.209] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.210] => (item=export JAVA_HOME=/usr/local/java/jdk8u392-b08)
changed: [10.2.102.209] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.208] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.210] => (item=export JRE_HOME=${JAVA_HOME}/jre)
changed: [10.2.102.209] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.208] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.210] => (item=export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib)
changed: [10.2.102.209] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.210] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.208] => (item=export PATH=${JAVA_HOME}/bin:${PATH})
changed: [10.2.102.209] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.210] => (item=# END ANSIBLE JAVA BLOCK)
changed: [10.2.102.208] => (item=# END ANSIBLE JAVA BLOCK)
ok: [10.2.102.209] => (item= )
ok: [10.2.102.210] => (item= )
ok: [10.2.102.208] => (item= )

TASK [install_hadoop : Set temporary file path for Hadoop tarball] ****************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_hadoop : Copy Hadoop tarball from local to the target] **************************************************************************
changed: [10.2.102.212]
changed: [10.2.102.215]
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.209]
changed: [10.2.102.210]
changed: [10.2.102.208]

TASK [install_hadoop : Extract directory name from downloaded tarball] ************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_hadoop : Set facts for Hadoop directories and config file] **********************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_hadoop : Get the JAVA_HOME environment variable] ********************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_hadoop : Set the fact for java_dir] *********************************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_hadoop : Get the alias of the namenode] *****************************************************************************************
ok: [10.2.102.211]
ok: [10.2.102.212]
ok: [10.2.102.213]
ok: [10.2.102.214]
ok: [10.2.102.215]
ok: [10.2.102.208]
ok: [10.2.102.209]
ok: [10.2.102.210]

TASK [install_hadoop : Create Hadoop base directory] ******************************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.212]
changed: [10.2.102.213]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_hadoop : Uncompress Hadoop tarball to the base directory] ***********************************************************************
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.215]
changed: [10.2.102.214]
changed: [10.2.102.208]
changed: [10.2.102.210]
changed: [10.2.102.209]

TASK [install_hadoop : Create Hadoop data and logs directories] *******************************************************************************
changed: [10.2.102.211] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.212] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.213] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.214] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.215] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.211] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.212] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.213] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.214] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.215] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.208] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.209] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.210] => (item=/opt/hadoop/hadoop-3.3.6/data)
changed: [10.2.102.208] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.209] => (item=/opt/hadoop/hadoop-3.3.6/logs)
changed: [10.2.102.210] => (item=/opt/hadoop/hadoop-3.3.6/logs)

TASK [install_hadoop : Generate Hadoop configuration and environment files from templates] ****************************************************
changed: [10.2.102.211] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.212] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.213] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.214] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.215] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.211] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.212] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.213] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.214] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.215] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.211] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.212] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.213] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.214] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.215] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.208] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.209] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.210] => (item={'src': 'hadoop-env.sh.j2', 'dest': 'hadoop-env.sh'})
changed: [10.2.102.208] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.209] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.210] => (item={'src': 'core-site.xml.j2', 'dest': 'core-site.xml'})
changed: [10.2.102.208] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.209] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})
changed: [10.2.102.210] => (item={'src': 'hdfs-site.xml.j2', 'dest': 'hdfs-site.xml'})

TASK [install_hadoop : Overwrite the workers file with datanode aliases, this task will only run on namenode] *********************************
skipping: [10.2.102.211]
skipping: [10.2.102.212]
skipping: [10.2.102.213]
skipping: [10.2.102.214]
skipping: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_hadoop : Cleanup downloaded Hadoop tarball] *************************************************************************************
changed: [10.2.102.211]
changed: [10.2.102.213]
changed: [10.2.102.212]
changed: [10.2.102.214]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_hadoop : Update ~/.bashrc to include HADOOP environment variables] **************************************************************
changed: [10.2.102.212]
changed: [10.2.102.211]
changed: [10.2.102.214]
changed: [10.2.102.213]
changed: [10.2.102.215]
changed: [10.2.102.208]
changed: [10.2.102.209]
changed: [10.2.102.210]

TASK [install_hadoop : Format the NameNode service] *******************************************************************************************
skipping: [10.2.102.211]
skipping: [10.2.102.212]
skipping: [10.2.102.213]
skipping: [10.2.102.214]
skipping: [10.2.102.215]
skipping: [10.2.102.209]
skipping: [10.2.102.210]
changed: [10.2.102.208]

TASK [install_hadoop : Start the HDFS system] *************************************************************************************************
skipping: [10.2.102.211]
skipping: [10.2.102.212]
skipping: [10.2.102.213]
skipping: [10.2.102.214]
skipping: [10.2.102.215]
skipping: [10.2.102.209]
skipping: [10.2.102.210]
changed: [10.2.102.208]

TASK [Prompt information] *********************************************************************************************************************
ok: [10.2.102.211] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.212] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.213] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.214] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.215] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.208] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.209] => {
    "msg": "All tasks of ansible roles have been completed ~"
}
ok: [10.2.102.210] => {
    "msg": "All tasks of ansible roles have been completed ~"
}

PLAY RECAP ************************************************************************************************************************************
10.2.102.208               : ok=44   changed=31   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.2.102.209               : ok=42   changed=29   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
10.2.102.210               : ok=42   changed=29   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
10.2.102.211               : ok=43   changed=30   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
10.2.102.212               : ok=41   changed=28   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
10.2.102.213               : ok=41   changed=28   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
10.2.102.214               : ok=41   changed=28   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
10.2.102.215               : ok=41   changed=28   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
```

3. Checking the status of the NameNode:

```bash
hadoop@namenode01:~$ hdfs dfsadmin -report
Configured Capacity: 341689835520 (318.22 GB)
Present Capacity: 312071426048 (290.64 GB)
DFS Remaining: 312071405568 (290.64 GB)
DFS Used: 20480 (20 KB)
DFS Used%: 0.00%
Replicated Blocks:
        Under replicated blocks: 0
        Blocks with corrupt replicas: 0
        Missing blocks: 0
        Missing blocks (with replication factor 1): 0
        Low redundancy blocks with highest priority to recover: 0
        Pending deletion blocks: 0
Erasure Coded Block Groups:
        Low redundancy block groups: 0
        Block groups with corrupt internal blocks: 0
        Missing block groups: 0
        Low redundancy blocks with highest priority to recover: 0
        Pending deletion blocks: 0

-------------------------------------------------
Live datanodes (5):

Name: 10.2.102.211:9866 (datanade01)
Hostname: datanade01
Decommission Status : Normal
Configured Capacity: 68337967104 (63.64 GB)
DFS Used: 4096 (4 KB)
Non DFS Used: 5931429888 (5.52 GB)
DFS Remaining: 62406533120 (58.12 GB)
DFS Used%: 0.00%
DFS Remaining%: 91.32%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Fri Jan 05 12:14:12 CST 2024
Last Block Report: Fri Jan 05 12:10:21 CST 2024
Num of Blocks: 0


Name: 10.2.102.212:9866 (datanode02)
Hostname: datanode02
Decommission Status : Normal
Configured Capacity: 68337967104 (63.64 GB)
DFS Used: 4096 (4 KB)
Non DFS Used: 5924126720 (5.52 GB)
DFS Remaining: 62413836288 (58.13 GB)
DFS Used%: 0.00%
DFS Remaining%: 91.33%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Fri Jan 05 12:14:12 CST 2024
Last Block Report: Fri Jan 05 12:10:21 CST 2024
Num of Blocks: 0


Name: 10.2.102.213:9866 (datanode03)
Hostname: datanode03
Decommission Status : Normal
Configured Capacity: 68337967104 (63.64 GB)
DFS Used: 4096 (4 KB)
Non DFS Used: 5921263616 (5.51 GB)
DFS Remaining: 62416699392 (58.13 GB)
DFS Used%: 0.00%
DFS Remaining%: 91.34%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Fri Jan 05 12:14:12 CST 2024
Last Block Report: Fri Jan 05 12:10:21 CST 2024
Num of Blocks: 0


Name: 10.2.102.214:9866 (datanode04)
Hostname: datanode04
Decommission Status : Normal
Configured Capacity: 68337967104 (63.64 GB)
DFS Used: 4096 (4 KB)
Non DFS Used: 5921239040 (5.51 GB)
DFS Remaining: 62416723968 (58.13 GB)
DFS Used%: 0.00%
DFS Remaining%: 91.34%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Fri Jan 05 12:14:12 CST 2024
Last Block Report: Fri Jan 05 12:10:21 CST 2024
Num of Blocks: 0


Name: 10.2.102.215:9866 (datanode05)
Hostname: datanode05
Decommission Status : Normal
Configured Capacity: 68337967104 (63.64 GB)
DFS Used: 4096 (4 KB)
Non DFS Used: 5920350208 (5.51 GB)
DFS Remaining: 62417612800 (58.13 GB)
DFS Used%: 0.00%
DFS Remaining%: 91.34%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Fri Jan 05 12:14:12 CST 2024
Last Block Report: Fri Jan 05 12:10:21 CST 2024
Num of Blocks: 0
```

4. Performing local HDFS file upload and download testing:

```bash
# Upload a file to HDFS:
hdfs dfs -put /path/to/local/file /path/in/hdfs

# Download a file from HDFS:
hdfs dfs -get /path/in/hdfs /path/to/local/directory

# Listing the contents of an HDFS directory:
hdfs dfs -ls /path/in/hdfs

# Deleting a file or directory in HDFS:
hdfs dfs -rm /path/in/hdfs/file
hdfs dfs -rm -r /path/in/hdfs/directory
```
