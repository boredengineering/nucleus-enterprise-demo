# Ansible Walkthrough

Before starting, create a directory inside the ansible diretory named: ```collections/ansible_collections```<br/>
For simplicity and educational purposes we will be installing the collections on the same directory as the playbooks.<br/>

Required Ansible-Galaxy Collections<br/>
> - amazon.aws
> - community.aws
> - community.general

## Summary
- Terraform generates the Static Inventory from a template<br/>
- Ansible uses the Static Inv and the Dynamic Inv to connect using SSM-agents instead of SSH<br/>
- Ansible performs its actions<br/>

## Step 1 - Configure Environment
If using Windows you must use WSL2 with Ubuntu distro. Once running WSL with an appropriate distro it should be similar between Windows or Linux users.<br/>

Run WSL2<br/>
> ```wsl```<br/>
Now all commands will be as if working on Ubuntu 22.04 LTS<br/>

**Activate Python venv**<br/>
> ```source .vev/bin/activate```<br/>

**Check Ansible installation**<br/>
> ```which ansible``` <br/>

**Configure the Env Var ANSIBLE_CONFIG**<br/>
Go to the directory with ansible.cfg then<br/>
> ```export ANSIBLE_CONFIG=$(pwd)```<br/>

For Using the SSO profile must setup the Environment Variable.<br/>
- For Linux<br/>
> ```export AWS_PROFILE="my-aws-sso-profile"```<br/>

**Check Ansible**<br/>
> ```ansible --version```<br/>

Should return the the path we setup for ANSIBLE_CONFIG and ...<br/>

Verify session-manager-plugin Installation<br/>
> ```something```<br/>

Check Collections<br/>
> ```ansible-galaxy collection list```<br/>

In the Ansible project folder:<br/>
> ```mkdir -p ./collections/ansible_collections```<br/>
> ```mkdir -p ./roles/galaxy```<br/>

If not already installed please install the required Collections<br/>
> ```ansible-galaxy install -r requirements.yml```<br/>

> ```ansible-galaxy collection install -r requirements.yml -p ./collections/```<br/>

## Step 2 - Configure SSM
**!!! Attention !!!**<br/>
The Instances must be running and SSM Fleet Manager must be able to communicate with them.<br/>
SSM plugin must be installed<br/>

Verify Instances on a specific region. <br/>
- Add proper region: **--region name-of-region**<br/>
- Add proper profile: **--profile profile-name**<br/>

> ```aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Ipv4:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --profile profile-name --region name-of-region``` <br/>

Start Instance<br/>
```aws ec2 start-instances --instance-ids i-1234567890abcdef0 --profile profile-name --region name-of-region```<br/>

Stop Instance<br/>
```aws ec2 stop-instances --instance-ids i-1234567890abcdef0 --profile profile-name --region name-of-region```<br/>

### Verify SSM connection<br/>
Connect to Reverse proxy<br/>
In knowledge of the proper Instance id for the Reverse Proxy<br/>
Example for instance-id: i-05ad7a9f1f73859fa<br/>
```properties
aws ssm start-session --target i-05ad7a9f1f73859fa --region name-of-region --profile profile-name
```
We should now have a session similar to SSH into the instance<br/>

Connect to nucleus server<br/>
In knowledge of the proper Instance id for the Nucleus Server<br/>
Example for instance-id: i-03a3a1e0dbb066566<br/>
```properties
aws ssm start-session --target i-03a3a1e0dbb066566 --region name-of-region --profile profile-name
```
We should now have a session similar to SSH into the instance<br/>

### Test Ansible SSM plugin<br/>
Test Ansible Dynamic Inventory<br/>
> ```ansible-inventory -i aws_ec2.yaml --list```<br/>
> ```ansible-inventory -i aws_ec2.yaml --graph```<br/>

Test Ansible connection to all instances<br/>
Currently dont have a ping playbook.<br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml ssm_ping.yaml```<br/>

## Step 3 - Run Playbooks
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nginx_install.yaml```<br/>

> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nucleus_install.yaml```<br/>

To Check on Stack, SSM into the instance and run:<br/>
> ```sudo docker-compose --env-file nucleus-stack.env  -f nucleus-stack-ssl.yml ps```<br/>

## Debug and Maintenance
There are a few playbooks designed to carry actions that are fairly common like start or stop or rebooting<br/>

**NGINX**<br/>
The playbook ```nginx_actions.yaml``` has a series of scripts that covers most <br/>

Start NGINX - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nginx_actions.yaml -e '{"nginx_action":"start"}'```<br/>

Restart NGINX - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nginx_actions.yaml -e '{"nginx_action":"restart"}'```<br/>

Stop NGINX - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nginx_actions.yaml -e '{"nginx_action":"stop"}'```<br/>

Uninstall NGINX - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nginx_actions.yaml -e '{"nginx_action":"uninstall"}'```<br/>

Need the extra_vars: -e '{"nginx_action":"start"}'<br/>

**Nucleus**<br/>
The playbook ```nucleus_actions.yaml``` has a series of scripts that covers most <br/>

Start Nucleus - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nucleus_actions.yaml -e '{"nucleus_action":"start"}'```<br/>

Stop Nucleus - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nucleus_actions.yaml -e '{"nucleus_action":"stop"}'```<br/>

Uninstall Nucleus - <br/>
> ```ansible-playbook -i static_inv.yaml -i aws_ec2.yaml nucleus_actions.yaml -e '{"nucleus_action":"uninstall"}'```<br/>

Need the extra_vars: -e '{"nucleus_action":"start"}'<br/>

## Appendix

### Ansible Misc
Ansible AWS SSM module requires the aws_ec2.yaml there is an example found in docs.<br/>

Collection of commands and insights regarding Ansible.<br/>

List the Installed Collections<br/>
```properties
ansible-galaxy collection list
```

Especify the config file via the ANSIBLE_CONFIG environment variable.<br/>
```properties
export NGINX_CONFIG=$(pwd)
export ANSIBLE_CONFIG=$(pwd)
```

Setup permanent environment variables<br/>
```properties
echo "export PATH=$(pwd):\${PATH}" >> ~/.bashrc
echo "export NGINX_CONFIG=$(pwd):\${PATH}" >> ~/.bashrc
```

Generate a sample ansible.cfg file<br/>
You can use these as starting points to create your own ansible.cfg file.<br/>
You can generate a fully commented-out example ansible.cfg file, for example:<br/>
```properties
ansible-config init --disabled > ansible.cfg
```

You can also have a more complete file that includes existing plugins:<br/>
```properties
ansible-config init --disabled -t all > ansible.cfg
```

Install Ansible roles or collections into a Python virtual environment<br/>
> ```ansible-galaxy install -r requirements.yml```<br/>
> ```ansible-galaxy collection install ..... -p collections```<br/>

### WSL misc
Some insights on Installing Ansible on WSL<br/>
**Windows filesystem weirdness**<br/>
If your Ansible directories live on a filesystem which has to emulate Unix permissions, like Vagrant or Windows Subsystem for Linux (WSL), you may, at first, not know how you can fix this as chmod, chown, and chgrp might not work there. <br/>

In most of those cases, the correct fix is to modify the mount options of the filesystem so the files and directories are readable and writable by the users and groups running Ansible but closed to others. For more details on the correct settings, see:<br/>

- for Vagrant, the Vagrant documentation covers synced folder permissions.<br/>
- for WSL, the WSL docs and this Microsoft blog post cover mount options.<br/>

If you absolutely depend on storing your Ansible config in a world-writable current working directory, you can explicitly specify the config file via the ANSIBLE_CONFIG environment variable.<br/> 
Please take appropriate steps to mitigate the security concerns above before doing so.<br/>

you must unmount drvfs and remount it with the ‘metadata’ flag. To do this:<br/>
```properties
sudo umount /mnt/c 
sudo mount -t drvfs C: /mnt/c -o metadata
sudo umount /mnt/d 
sudo mount -t drvfs D: /mnt/d -o metadata
sudo umount /mnt/e 
sudo mount -t drvfs E: /mnt/e -o metadata
```
## TODO

Directory group_vars is created with Terraform based on nginx.tftpl and nucleus.tftpl templates.<br/>
Unfortunately, this is the easiest and possibly the only way to get some important information about the Infrastructure into Ansible<br/>


- nucleus stack template Need changes
- INSTANCE_NAME could use a variable
- MASTER_PASSWORD could use a variable
- SERVICE_PASSWORD could use a variable


Need to add logic to dynamically generate templates. 

Need to have a playbook to install, update, delete

Need Playbooks for managing

Add some way to collect metrics on the ingress and the Docker compose

If running on top of data from an older version of Nucleus, data upgrade
may be required. <br/>

Use `nucleus-upgrade-db.yml` stack along with this .env file to perform the upgrade.<br/>
> ```sudo docker-compose --env-file nucleus-stack.env  -f nucleus-stack-ssl.yml -f nucleus-upgrade-db.yml up -d```<br/>

To validate internal consistency of data, use `nucleus-verify-db.yml` along with this .env file to run the verifier tool. <br/>
> ```sudo docker-compose --env-file nucleus-stack.env  -f nucleus-stack-ssl.yml -f nucleus-verify-db.yml up -d```<br/>

So the stack will be installed on /opt/ove/<br/>
The tarball will unarchive and whatever the name of the tarball in the artifacts be it will be on the path.<br/>

Example if nucleus-stack.tar.gz<br/>
/opt/ove/nucleus-stack/base_stack<br/>

Change the path /opt/ove/nucleus-stack/base_stack<br/>

### Docker

Latest: 

### Docker Compose

Latest: v2.29.3