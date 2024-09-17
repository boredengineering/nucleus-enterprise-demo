# Cheatsheet for CLI commands

List of commands and useful notes

## Docker

Script to build the container image

```bash
#!/bin/bash

SELF_DIR="$(realpath "$(dirname "${BASH_SOURCE}")")"
TAG="isa"

docker build --platform linux/x86_64 -t "${TAG}" "${SELF_DIR}"
```

Commands:

Should build the Doker image to run the Stuff:

```terminal
docker build --platform linux/x86_64 -t isa .
```

## Terraform

Login with your AWS SSO profile<br/>
> ```aws sso login --profile my-aws-sso-profile```<br/>

For Using the SSO profile must setup the Environment Variable.<br/>
- For Linux<br/>
> ```export AWS_PROFILE="my-aws-sso-profile"```<br/>
- For Windows<br/>
> ```$Env:AWS_PROFILE = "my-aws-sso-profile"```<br/>

If Profile is not specified inside Terraform Provider must provide the Profile.

```terraform init --profile <sso-profile-name>```

```terraform plan --profile <sso-profile-name>```

```terraform apply --profile <sso-profile-name>```



## Ansible



## Packer



## AWS CLI

Download Nucleus Stack from S3
> ```cd ~ ```<br/>
> ```aws s3 cp s3://artifactsbucket-20230707003003658200000002/nucleus-stack.tar.gz ./nucleus-stack.tar.gz```<br/>

Start Instance<br/>
```aws ec2 start-instances --instance-ids i-1234567890abcdef0```<br/>

> ```aws ec2 --region us-east-1 get-associated-enclave-certificate-iam-roles --certificate-arn cert-arn --profile my-aws-sso-profile```

Fetch Instace Id based on the Name

Verify Instances on a specific region. <br/>
- Add proper region: **--region name-of-region**<br/>
- Add proper profile: **--profile profile-name**<br/>

> ```aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Ipv4:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --region name-of-region --profile <profile-name>``` <br/>

Start SSM Session with the instance ID

```properties
aws ssm start-session --target i-03a3a1e0dbb066566 --region name-of-region --profile profile-name
```

> ```aws s3 ls --profile profile-name```<br/>
> ```aws s3 ls s3://bucket-name --recursive --profile profile-name```<br/>

### Find Images (AMIs)

Looking for the ACM-For-Nitro-Enclaves Images:

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'sort_by(Images, &CreationDate)[].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

```terminal
aws ec2 describe-images --owners 679593333241 --filters "Name=name,Values=ACM-For-Nitro-Enclaves*" --region us-west-2 --query 'Images[*].[ImageId]' --output json --region us-west-2 --include-deprecated --profile <profile-name>
```

Looking for the Ubuntu Images for the Nucleus Server:

Owner id: 099720109477 for canonical Ubuntu
Name: ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server


Return the Latest Canonical Ubuntu Image:
```terminal
aws ec2 describe-images --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*" --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-east-1 --profile <profile-name>
```

- Find Nvidia AMI id <br/>
> ```aws ec2 describe-images --owners aws-marketplace --filters "Name=name,Values=OV AMI 1.3.6*" --query 'Images[*].[ImageId]' --region us-east-1 --output table --profile <profile-name>```<br/>

> ```aws ec2 describe-images --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*" --query 'Images[*].[ImageId]' --region us-east-1 --output json --profile <profile-name>```<br/>

> ```aws ec2 describe-images --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*" --query 'Images[*].[ImageId]' --region us-east-1 --output json --profile <profile-name>```<br/>

> ```aws ec2 describe-images --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*" --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-east-1 --profile <profile-name>```<br/>

> ```aws ec2 describe-images --filters "Name=name, Values=ubuntu-pro-server/images/hvm-ssd/ubuntu-jammy-22.04-amd64-pro*" --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-east-1 --profile <profile-name>```<br/>

> ```aws ec2 describe-images --filters "Name=image-id, Values=ami-05421ae6be0ecba36" --query 'sort_by(Images, &CreationDate)[-1].{Name: Name, ImageId: ImageId, CreationDate: CreationDate, Owner:OwnerId}' --output json --region us-west-2 --profile <profile-name>```<br/>

## GCP CLI
