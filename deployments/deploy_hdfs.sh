#!/bin/bash

# Vault password
vault_password="1qaz!QAZ"

# Vault securts file
vault_file="/etc/ansible/secrets/secrets_stage.yml"

# Inventory group
inventory_group="hdfs"

# Inventory hosts file
inventory_file="/etc/ansible/inventories/hosts_stage"

# Playbook file
playbook_file="/etc/ansible/playbooks/hadoop_hdfs.yml"

# Execute the playbook
sshpass -p ${vault_password} \
  ansible-playbook \
    -i ${inventory_file} \
    -e "target_hosts=${inventory_group}" \
    -e "vault_file=${vault_file}" \
    --ask-vault-pass \
    ${playbook_file}

#EOF
