# NVIDIA-nucleus-aws
**!!! Attention !!!** <br/>
- Uses multiple services and softwares that are **NOT FREE** !!
- The Artifacts directory must contain nucleus-stack as tarball

This repo contains a IaC solution to deploy Nvidia Nucleus Enterprise on AWS.<br/>

Requires:<br/>
- Terraform<br/>
- Ansible<br/>
- Docker & Podman<br/>
- Python<br/>
- Nucleus Enterprise<br/>

Optional:<br/>
- SSO (Azure AD or others ...)<br/>

Authors:<br/>
> - Pappachuck (find me on Discord for any questions) <br/>

instance types<br/>
- c5.4xlarge
- c5.xlarge

Current Issues<br/>
- Lots of dependencies and requirements
- Difficulty to generate a proper Strategy for Ansible EE

Solutions<br/>
- Ansible EE makes easier to manage, but requires more study

## Objective
The idea is to create a Cloud Agnostic solution that abstracts most of the challenges of deploying and maintaining Nvidia Nucleus Enterprise into simple concepts easy to replicate and modify into any project.<br/>

### What we will be Deploying
- NGINX Reverse Proxy Server <br/>
- Nvidia Nucleus Enterprise Server <br/>
- Nvidia Farm <br/>
- Nvidia DeepSearch <br/>

## Pre-requisites
- Setup AWS SSO profile (recommended over static credentials)<br/>
- Setup Python Virtual Environment<br/>
- Setup Ansible EE<br/>
For Windows users<br/>
- Setup WSL2 with Ubuntu distro<br/>

### Setup AWS SSO profile
Check your configured Profiles<br/>
> ```aws configure list-profiles```<br/>

If not configured please properly configure a SSO profile<br/>
> ```aws configure sso --profile my-aws-sso-profile```<br/>

Login with your AWS SSO profile<br/>
> ```aws sso login --profile my-aws-sso-profile```<br/>

For Using the SSO profile must setup the Environment Variable.<br/>
- For Linux<br/>
> ```export AWS_PROFILE=my-aws-sso-profile```<br/>
- For Windows<br/>
> ```$Env:AWS_PROFILE = "my-aws-sso-profile"```<br/>

### Setup WSL2 with Ubuntu distro
TODO !

### Setup Python Virtual Environment
#### !!!Attention!!! Windows may have issue with Execution Policies
If using Windows highly reccomend to install the Python Virtual Environment inside the WSL2 distro.<br/>

- Check the current ExecutionPolicy setting.<br/>
> ```get-ExecutionPolicy```<br/>

- Allows to run the virtual envinronment in the current PowerShell session.<br/>
> ```Set-ExecutionPolicy Unrestricted -Scope Process```<br/>

- You can revert back to this ExecutionPolicy by using.<br/>
> ```Set-ExecutionPolicy %the value the get-ExecutionPolicy command gave you% -Force```<br/>


