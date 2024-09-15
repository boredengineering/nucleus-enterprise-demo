# Terraform Walkthrough

If running on Windows I highly reccomend to use WSL2, for your own mental sanity.<br/> 
Otherwise there will be a need for 2 Python Virtual Environments and 2 separate Configurations.<br/>

**Requirements**<br/>
> - Public Cloud account (ex.: AWS)<br/>
> - Region to deploy (eg.: us-east-1, ...)<br/>
> - Adequated permissions <br/>
> - FQDN (Fully Qualified Domain Name), reccomend Route 53<br/>
> - Subdomain<br/>
> - All artifacts (nucleus-stack, farm, deepsearch, ...) must be in the artifacts directory<br/>


**Summary**<br/>
> - Generate sample.auto.tfvars<br/>
> - Run Terraform<br/>
> - Verify if ACM certs are associated to the Proxy instance <br/>
> - Verify SSM connection<br/>

TODO - Table of Contents

## Step 1 - Setup WSL
1- get right WSL2 distro (ex.: Ubuntu 22.04 LTS)<br/>
2- Install AWS CLI<br/>
3- Create a Python venv.<br/>

Commands<br/>
List all distros that you can install from a Command Prompt:<br/>
> ```wsl --list --online```<br/>

The list contained the desired Ubuntu-22.04, so we can install it with:<br/>
> ```wsl --install -d Ubuntu-22.04```<br/>
> ```wsl --install --distribution Ubuntu-22.04```<br/>

to set it as the default container:<br/>
> ```wsl --setdefault Ubuntu-22.04```<br/>

### Install Terraform on WSL2<br/>
Go to Terraform and grab the download URL. https://developer.hashicorp.com/terraform/downloads<br/>
> ```wget terraform_url -O terraform.zip```<br/>
> ```unzip terraform.zip```<br/>
> ```sudo mv terraform /usr/local/bin```<br/>
> ```rm terraform.zip```<br/>

Example<br/>
> ```wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -O terraform.zip```<br/>
> ```unzip terraform.zip```<br/>
> ```sudo mv terraform /usr/local/bin```<br/>
> ```rm terraform.zip```<br/>

Check Terraform<br/>
> ```terraform -v```<br/>

### Install AWS CLI on WSL2<br/>

```properties
lscpu
uname -r
lsb_release -a
sudo apt install unzip
aws --version
sudo apt update -y && sudo apt upgrade -y
sudo apt install glibc-source groff less unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
pip3 install --upgrade awscli
```

### Install and Create a Python VENV on WSL2<br/>
Install Python venv<br/>
> ```sudo apt install python3-pip```<br/>
> ```sudo apt install python3-venv```<br/>

Create a Python venv on WSL2<br/>
> ```python3 -m venv name_of_virtual_env```<br/>
Example<br/>
> ```python3 -m venv .venv```<br/>

Activate the Virtual Environment
> ```source .venv/bin/activate```<br/>

### Install Python Dependencies<br/>
Install all python dependencies<br/>
> ```python3 -m pip install -r requirements.txt```<br/>

You can also manually install them and try different versions.<br/>
> ```python3 -m pip install ansible```<br/>
> ```python3 -m pip install boto3```<br/>

**Attention!!!** - Ansible is pretty heavy and slow to install.<br/>

Confirm Ansible version<br/>
> ```which ansible```<br/>

You should see something like this when running ```pip freeze```.

> List of Project Dependencies:<br/>
> - ansible==2.9<br/>
> - ansible-core<br/>
> - boto3<br/>
> - botocore<br/>
> - cffi<br/>
> - cryptography<br/>
> - Jinja2<br/>
> - jmespath<br/>
> - MarkupSafe<br/>
> - packaging<br/>
> - pycparser<br/>
> - python-dateutil<br/>
> - PyYAML<br/>
> - resolvelib<br/>
> - s3transfer<br/>
> - six<br/>
> - urllib3<br/>


### Install the Session Manager plugin on Ubuntu<br/>
```properties
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

### Setup AWS SSO profile
Check your configured Profiles<br/>
> ```aws configure list-profiles```<br/>

If not configured please properly configure a SSO profile<br/>
> ```aws configure sso --profile my-aws-sso-profile```<br/>

Login with your AWS SSO profile<br/>
> ```aws sso login --profile my-aws-sso-profile```<br/>

For Using the SSO profile must setup the Environment Variable.<br/>
- For Linux<br/>
> ```export AWS_PROFILE="my-aws-sso-profile"```<br/>
- For Windows<br/>
> ```$Env:AWS_PROFILE = "my-aws-sso-profile"```<br/>

Print Environment Variable.<br/>
- For Linux<br/>
> ```echo $AWS_PROFILE```<br/>
Should print<br/>
> my-aws-sso-profile<br/>

## Step 2 - Create a tfvars
Create a sample.auto.tfvars with the following variables:<br/>

```properties
# Region to deploy
region="us-west-2"
# FQDN
domain_name = "mydomain.com"
subdomain_name = "nucleus"
# SSO Profile Name
profile_name = "pappachuck"
# Nucleus Enterprise Server
nucleusServer_instance_name = "Nucleus-Server"
nucleusServer_instance_type = "c5.4xlarge"
# NGINX Reverse Proxy Server
proxyServer_instance_name = "Nucleus-ReverseProxy"
proxyServer_instance_type = "c5.xlarge"
```

## Step 3 - Run Terraform
Either setup the profile on the Terraform provider.tf or on CLI include ```--profile my-sso-profile-name```<br/>
Commands:<br/>
> ```terraform init```<br/>
> ```terraform plan```<br/>
> ```terraform apply```<br/>

If everything runs correctly it should take approx 5 mins (maybe include image)

## Step 4 - Verify ACM certs
For properly setting up SSL for the NGINX reverse proxy with the Nitro Enclaves Instance the ACM certificates must be properly associated.<br/>
Commands<br/>
> ```aws ec2 --region us-east-1 get-associated-enclave-certificate-iam-roles --certificate-arn cert-arn --profile my-aws-sso-profile```

- Associate Certs<br/>
> ```python associate_enclave.py```<br/>

Associates an Identity and Access Management (IAM) role with an Certificate Manager (ACM) certificate. This enables the certificate to be used by the ACM for Nitro Enclaves application inside an enclave. <br/>

For more information, see Certificate Manager for Nitro Enclaves in the Amazon Web Services Nitro Enclaves User Guide.
https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave-refapp.html<br/>

get-associated-enclave-certificate-iam-roles <br/>
Returns the IAM roles that are associated with the specified ACM certificate. It also returns the name of the S3 bucket and the S3 object key where the certificate, certificate chain, and encrypted private key bundle are stored, and the ARN of the KMS key that’s used to encrypt the private key.

## Step 5 - Verify SSM connection
Required for Running Ansible<br/>

Verify Instances on a specific region. <br/>
- Add proper region: **--region name-of-region**<br/>
- Add proper profile: **--profile profile-name**<br/>

> ```aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Ipv4:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --profile profile-name --region name-of-region``` <br/>

### SSM connection to reverse proxy<br/>
Fetch Instace Id based on the Name: ```Nucleus-ReverseProxy```<br/>

Example of Instance ID:<br/>
> - instance-id: `i-05ad7a9f1f73859fa`<br/>

With the instance run the command:<br/>
```properties
aws ssm start-session --target i-05ad7a9f1f73859fa --region name-of-region --profile profile-name
```
In your terminal .....<br/>

### SSM connection to nucleus server<br/>
Fetch Instace Id based on the Name: ```Nucleus-Server```<br/>

Example of Instance ID:<br/>
> - instance-id: `i-03a3a1e0dbb066566`<br/>

With the instance run the command:<br/>
```properties
aws ssm start-session --target i-03a3a1e0dbb066566 --region name-of-region --profile profile-name
```
In your terminal .....<br/>

## Step 6 - Verify S3 Artifacts 
Check if the Nucleus Stack as uploaded to S3.<br/>
> ```aws s3 ls --profile profile-name```<br/>
> ```aws s3 ls s3://bucket-name --recursive --profile profile-name```<br/>

## Cleaning
**!!!Attention!!!** - Terraform might delete the script to disassociate the ACM certs<br/>
- Backup the Python Script `disassociate_enclave.py`

If Terraform deletes the script before executing it during **Terraform Destroy** it Will fail to Completely Destroy the Cluster, and might raise an Error.<br/>
It can be Fixed by manually running the Backed up script `disassociate_enclave.py`<br/>
> ```python disassociate_enclave.py```<br/>

## Appendix
ACM certs<br/>
- Associate Certs<br/>
> ```python associate_enclave.py```<br/>
- Disassociate Certs (required to run Terraform destroy)<br/>
> ```python disassociate_enclave.py```<br/>


Disassociates an IAM role from an Certificate Manager (ACM) certificate. Disassociating an IAM role from an ACM certificate removes the Amazon S3 object that contains the certificate, certificate chain, and encrypted private key from the Amazon S3 bucket. It also revokes the IAM role's permission to use the KMS key used to encrypt the private key. This effectively revokes the role's permission to use the certificate.

> ```python associate_enclave.py```<br/>

This script Associates an Identity and IAM role with a AWS Certificate Manager (ACM) certificate. 
This enables the certificate to be used by the ACM for Nitro Enclaves application inside an enclave. 
For more information, see Certificate Manager for Nitro Enclaves in the Amazon Web Services Nitro Enclaves User Guide. 

The script then updates the IAM role policy with permissions to get its own role, download the certificate, and decrypt it.
https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave-refapp.html

What we need:
CERT_ARN = tls-certificate-arn
ROLE_ARN = proxy-instance-role-arn
ROLE_POLICY_ARN = proxy-cert-association-policy-arn

### ACM for Nitro Enclaves

It is important to find the correct AMI ID for your Region to properly setup the Proxy server using AWS Nitro-Enclaves. You can do that through the AWS Marketplace or running the AWS CLI command ```aws ec2 describe-images```.

Examples:

- Find the Latest Image information for **"ACM-For-Nitro-Enclaves"** for a particular region:

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

Should Output:

```json
{
    "Name": "ACM-For-Nitro-Enclaves-1-2-0_2022-09-09T11-07-26.526Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9",
    "ImageId": "ami-05421ae6be0ecba36",
    "CreationDate": "2022-09-12T13:46:52.000Z",
    "Owner": "679593333241"
}
```

- Find all **"ACM-For-Nitro-Enclaves"** AMI ids for a particular region:

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'Images[*].[ImageId]' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

Should Output:

```json
[
    [
        "ami-01c4415fd6c2f0927"
    ],
    [
        "ami-031a76fec7387f3f5"
    ],
    [
        "ami-05421ae6be0ecba36"
    ]
]
```

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'sort_by(Images, &CreationDate)[].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

Should Output:

```json
[
    {
        "Name": "ACM-For-Nitro-Enclaves-1-0-1_2020-11-20T18-14-09.162Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9-ami-09a1f053468bd3dcf.4",
        "ImageId": "ami-031a76fec7387f3f5",
        "CreationDate": "2021-01-06T16:07:51.000Z",
        "Owner": "679593333241"
    },
    {
        "Name": "ACM-For-Nitro-Enclaves-1-0-2_ 2021-04-29T21-09-41.751Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9-ami-028ce88e069714286.4",
        "ImageId": "ami-01c4415fd6c2f0927",
        "CreationDate": "2021-04-30T00:01:19.000Z",
        "Owner": "679593333241"
    },
    {
        "Name": "ACM-For-Nitro-Enclaves-1-2-0_2022-09-09T11-07-26.526Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9",
        "ImageId": "ami-05421ae6be0ecba36",
        "CreationDate": "2022-09-12T13:46:52.000Z",
        "Owner": "679593333241"
    }
]
```

The list of AMIs on Nvidia demo:

https://docs.omniverse.nvidia.com/nucleus/latest/enterprise/cloud/cloud_aws_ec2.html

**ATTENTION** - These AMIs are outdated

> - 'us-west-1': 'ami-0213075968e811ea7',    //california
> - 'us-west-2': 'ami-01c4415fd6c2f0927',    //oregon
> - 'us-east-1': 'ami-00d96e5ee00daa484',    //virginia
> - 'us-east-2': 'ami-020ea706ac260de21',    //ohio
> - 'ca-central-1': 'ami-096dd1150b96b6125', //canada
> - 'eu-central-1': 'ami-06a2b19f6b97762cb', //frankfurt
> - 'eu-west-1': 'ami-069e205c9dea19322',    //ireland
> - 'eu-west-2': 'ami-069b79a2d7d0d9408'     //london

