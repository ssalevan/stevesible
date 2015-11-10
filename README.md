stevesible
==========

This repository contains some Ansible automation that I've been collecting over the past few years; it features the following functionality:

 * Automated EC2 and Linode provisioning
 * Battle-tested Ansible roles to help you do things with computers:
   * Aurora/Mesos
   * Docker
   * Elasticsearch
   * nginx
   * Various GNU utilities
   * OpenLDAP
   * Python/Ruby for old-school Red Hat
   * stunnel
   * ZooKeeper

This automation was largely targeted towards EL6/7, though much of it works against Debian flavors as well.

Getting Started
---------------

1. Install Python 2.7 and virtualenv to support running Ansible:

```bash
# OS X
sudo easy_install-2.7 pip
sudo pip install virtualenv

# Old-school RH
sudo yum install -y centos-release-SCL
sudo yum install -y python27 python27-virtualenv
scl enable python27

# Newer-school RH
sudo yum install -y python-virtualenv
```

2. Run the environment setup script to install Ansible and all its deps:

```bash
./setup_ansible
```

3. Provision up a new set of power user AWS credentials in IAM and record them in ~/.boto:

```bash
cat <<EOF > ~/.boto
[Credentials]
aws_access_key_id = <your aws access key>
aws_secret_access_key = <your aws secret key>
EOF
```

By doing so, you'll provide all of Ansible's AWS tie-ins with the necessary credentials to
make changes to your infrastructure.

Navigating the Helper Scripts
-----------------------------

This repository is packaged with a number of helper scripts to simplify your Ansible experiences.  They wrap the core bits of Ansible's functionality, using binaries within your virtualenv, and tie
in with the ec2 inventory module to ensure that you don't have to maintain local host files.

Additionally, the inventory script provides Ansible with you a rich set of groups against which
automation can be targeted, using information like tags, IDs, and security groups.  To see what
those are, run the inventory script directly:

```bash
./inventory/ec2

...
  "ami_c2a818aa": [
    "54.164.77.1",
    "54.152.250.149"
  ],
  "ec2": [
    "54.164.77.1",
    "54.152.250.149"
  ],
  "i-fe6abb00": [
    "54.164.77.1"
  ],
  "i-ff6abb01": [
    "54.152.250.149"
  ],
  "key_ansible_steve": [
    "54.164.77.1",
    "54.152.250.149"
  ],
  "tag_Name_elasticsearch_48461473": [
    "54.164.77.1"
  ],
  "tag_ansible_group_elasticsearch": [
    "54.164.77.1"
  ],
...
```

Each one of these groups can be used to target automation via the **hosts:** playbook
directive.

If in the wild, you see someone using one of the following commands, you can substitute in
one of our helper scripts, just ignore any -i or -u args as we cover them:

 * **a**: ansible
 * **play**: ansible-playbook
 * **vplay**: ansible-playbook --ask-vault-pass -e @vault/creds.yml

If you'd like to use these tools directly, activate your virtualenv and they should be on
your PATH:

```bash
source env/bin/activate
```

Additionally, two further helper scripts are provided to simplify provisioning and
updates:

 * `./provision <ANSIBLE_GROUP> <NUMBER_OF_NODES>`
   - Provisions one or more nodes from EC2, assigns them a tag of
     ansible_group: $ANSIBLE_GROUP, and bootstraps them.
 * `./bootstrap <ANSIBLE_GROUP>`
   - Runs the bootstrap code (which will update the base system) for all nodes with a tag
     of ansible_group: $ANSIBLE_GROUP

Structure
---------

This repo makes heavy use of Ansible [roles](https://docs.ansible.com/playbooks_roles.html) to enable greater flexibility when spinning up new server classes.

Automation for each server class can be found in the base of the repo; for instance, this playbook establishes Elasticsearch across all nodes in the **tag_ansible_group_elasticsearch** group:

```yaml
---
- name: Establishes and maintains an elastic
  hosts: tag_ansible_group_es_data
  sudo: true

  vars:
    elasticsearch_cluster_name: stevesible
    elasticsearch_plugin_aws_access_key: "{{ vault_aws_access_key }}"
    elasticsearch_plugin_aws_secret_key: "{{ vault_aws_secret_key }}"

  roles:
    - elasticsearch
```

To add a new role to a server class, simply add it to the list, then override any default
variables in the **vars:** section.

Using the Vault
---------------

Secure credentials can be stored in git using the ansible-vault tool, which encrypts them
with a password.  To edit these credentials:

```bash
source env/bin/activate
ansible-vault edit vault/creds.yml
```

This will prompt you for a password; ask whoever's maintaining the systems for what that
is.  If you'd like to change that password:

```bash
source env/bin/activate
ansible-vault rekey vault/creds.yml
```

Bugs? Questions?
----------------

I've made all efforts to ensure the correctness and functionality of these scripts, but
if you run into any problems, e-mail me at steve.salevan@gmail.com.