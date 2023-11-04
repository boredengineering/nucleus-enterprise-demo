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


Below need organizing<br/>


Currently at Experiment 6<br/>
Experiment 6 - Terraform + Ansible deploy Nucleus enterprise server<br/>

ACM certs<br/>
- Associate Certs<br/>
> ```python associate_enclave.py```<br/>
- Disassociate Certs (required to run Terraform destroy)<br/>
> ```python disassociate_enclave.py```<br/>

## Terraform Stuff
Before deploying must have the following:
- Region to deploy (eg.: us-east-1, ...)<br/>
- FQDN (Fully Qualified Domain Name)<br/>
- Subdomain<br/>
- All artifacts (nucleus-stack, farm, deepsearch, ...) must be in the artifacts directory<br/>

Create a sample.auto.tfvars with the following variables:<br/>

```properties
# Region to deploy
region="eu-north-1"
# FQDN
domain_name = "cineshare.org"
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

Run the following commands and review the changes<br/>
> terraform init<br/>
> terraform plan<br/>
> terraform deploy<br/>


Check the infrastructure state by running some AWS-CLI commands, as example:<br/>

Verify Instances on a specific region. <br/>
- Add proper region: **--region name-of-region**<br/>
- Add proper profile: **--profile profile-name**<br/>

> ```aws ec2 describe-instances --filters Name=tag-key,Values=Name --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Ipv4:PublicIpAddress,State:State.Name,Name:Tags[?Key=='Name']|[0].Value}" --output table --profile profile-name --region name-of-region``` <br/>

Once you double checked everything was created and is running accordingly is time to deploy Ansible.<br/>

## Ansible Stuff
For this simple deployment, Ansible is being used to configure and maintain the following:<br/>
- NGINX Proxy instance <br/>
- Nucleus Instance <br/>

> ```export ANSIBLE_CONFIG=$(pwd)```<br/>

Before proceding double check if AWS SSM can stablish a connection.<br/>
```properties
ansible-inventory -i static_inv.yaml -i aws_ec2.yaml --graph
ansible-playbook -i static_inv.yaml -i aws_ec2.yaml ssm_ping.yaml
```

```properties
ansible -i static_inv.yaml -i aws_ec2.yaml nucleus -m setup
ansible -i static_inv.yaml -i aws_ec2.yaml nginx -m setup
```

Setup Ansible EE <br/>

Run the playbooks <br/>

### NGINX Proxy instance<br/>
For Setting up a NGINX reverse proxy instance based on AWS Nitro Enclaves required for using Nucleus Enterprise there 3 main files we must configure:<br/>
- acm.yaml <br/>
- nginx.conf <br/>
- nginx.ingress.router.conf <br/>

**For acm.yaml**<br/>
In this example of setting up ACM, with Nitro Enclaves and nginx. We are mostly focused on configuring the certificate_arn<br/>

```properties
Acm:
        # The certificate ARN - tls-certificate-arn
        # Note: this certificate must have been associated with the
        #       IAM role assigned to the instance on which ACM for
        #       Nitro Enclaves is run.
        certificate_arn: "{{ cert_arn }}"
```
**For nginx.conf**<br/>
It is a simple NGINX deployment that will be Loading modular configuration files from the /etc/nginx/conf.d directory.<br/>
It is templated for Ansible for the practicity of implementing changes in the future. <br/>

**For nginx.ingress.router.conf**<br/>
This modular configuration file must go into the /etc/nginx/conf.d directory and contain the following modifications:<br/>
- server_name {{ domain }};
- return 200 '{{ domain }}';
- return 302 https://{{ domain }}$request_uri;

When Terraform finishes seting up the base infrastructure it will provide us with the BASE_STACK_IP_OR_HOST.<br/>
We must substitute all BASE_STACK_IP_OR_HOST inside proxy_pass to match the AWS private IP<br/>
Example:<br/>
> ```proxy_pass http://BASE_STACK_IP_OR_HOST.internal:8080```<br/>
> ```proxy_pass http://{{ base_stack_ip_or_host }}:8080```<br/>
> e.g.: ip-10-0-3-111.ec2.internal<br/>
> ```proxy_pass http://ip-10-0-3-111.ec2.internal:8080```<br/>

Default root redirect to Navigator (routed via `/omni/web3`)<br/>
- return 302 https://{{ domain }}/omni/web3;<br/>

These changes are Automated by Ansible through JINJA 2 templating and changes might be required accordingly.

### Nucleus Enterprise Instance<br/>
Attention !!! this deployment only includes the SSL not the SSO.<br/>

Nucleus Enterprise is being deployed Using Docker Compose and dependent on a list of environment variables stored in nucleus-stack.env<br/>

On nucleus-stack.env we must modify the following variables:<br/>
> ACCEPT_EULA       = 1<br/>
> SECURITY_REVIEWED = 1<br/>
> SERVER_IP_OR_HOST = BASE_STACK_IP_OR_HOST<br/>
> SSL_INGRESS_HOST  = nucleus.boredengineer.com (full domain name)<br/>
> MASTER_PASSWORD   = 123456<br/>
> SERVICE_PASSWORD  = 123456<br/>
> DATA_ROOT         = /var/lib/omni/nucleus-data<br/>
> CONTAINER_SUBNET  = 192.168.2.0/26<br/>
> INSTANCE_NAME     = Nucleus-Server<br/>
> WEB_PORT          = 8080<br/>

On deepsearch-stack.env we must modify the following variables:<br/>
> ACCEPT_EULA                             = 1<br/>
> SECURITY_REVIEWED                       = 1<br/>
> SERVER_IP_OR_HOST                       = The IP or Host where DeepSearch is <br/>
> SSL_INGRESS_HOST                        = nucleus.boredengineer.com (full domain name)<br/>
> INSTANCE_NAME                           = <br/>
> BASE_STACK_IP_OR_HOST                   = hostname or IP where Nucleus Base Stack is running<br/>
> SERVICE_USERNAME                        = omniverse<br/>
> SERVICE_PASSWORD                        = 123456<br/>
> ALL of the below secrets are required, and values provided are not DEFAULTS<br/>
> AUTH_ROOT_OF_TRUST_PUB                  = ./secrets/auth_root_of_trust.pub (Nucleus's auth root of trust public)<br/>
> DISCOVERY_REGISTRATION_TOKEN            = ./secrets/svc_reg_token (Nucleus's Discovery Registration Token)<br/>
> SEARCH_BACKEND_TYPE                     = os_index (OpenSearch - os_index , Elastic Search - es_index)<br/>
> Leaving the following configuration parameters as default will automatically connect NGSearch services to the test OpenSearch Search installation that is deployed in parallel to the stack<br/>
> SEARCH_BACKEND_HOST                     = open-search<br/>
> SEARCH_BACKEND_PORT                     = 9200<br/>
> SEARCH_BACKEND_SCHEMA                   = http<br/>
> SEARCH_BACKEND_NUMBER_OF_SHARDS         = 10<br/>
> The variables below can be used for authentication to the ElasticSearch cluster.<br/>
> When using the test installation, authentication is not required, as ElasticSearch endpoint is not exposed anywhere outside the container network that is used only by the NGSearch stack for internal communication.<br/>
> SEARCH_BACKEND_USERNAME                 = <br/>
> SEARCH_BACKEND_PASSWORD                 = <br/>
> SEARCH_BACKEND_CLOUD_ID                 = <br/>
> SEARCH_BACKEND_BEARER_AUTH              = <br/>
> SEARCH_BACKEND_OPAQUE_ID                = <br/>
> SEARCH_BACKEND_API_KEY                  = <br/>
> SEARCH_BACKEND_HOSTS                    = <br/>
> NGSEARCH_DATA_ROOT                      = /var/lib/omni/ngsearch-data/<br/>
> NGSEARCH_PORT                           = 3503<br/>
> NGSEARCH_STORAGE_PORT                   = 3703<br/>
> INDEXING_METRICS_PORT                   = 8001<br/>
> TAGGING_METRICS_PORT                    = 8002<br/>
> STORAGE_METRICS_PORT                    = 8007<br/>
> NGSEARCH_METRICS_PORT                   = 8008<br/>
> CONTAINER_SUBNET                        = 192.168.2.196/26<br/>
> USE_SEARCH_TELEMETRY                    = 0<br/>
> SEARCH_TELEMETRY_STDOUT                 = 0<br/>
> DEFAULT_SEARCH_SIZE                     = 64<br/>
> REGISTRY                                = nvcr.io/nvidia/omniverse<br/>
> DEEPSEARCH_DATA_ROOT                    = /var/lib/omni/deepsearch-data/<br/>
> EMBEDDING_SERVICE_PORT                  = 3603<br/>
> MONITOR_API_PORT                        = 3504<br/>
> MONITOR_CACHE_PORT                      = 8778<br/>
> DEEPSEARCH_CACHE_METRICS_PORT           = 8010<br/>
> DEEPSEARCH_FARM_WORKER_METRICS_PORT     = 8011<br/>
> DEEPSEARCH_NON_FARM_WORKER_METRICS_PORT = 8012<br/>
> DEEPSEARCH_OMNI_WRITER_METRICS_PORT     = 8013<br/>
> DEEPSEARCH_MONITOR_METRICS_PORT         = 8014<br/>
> DEEPSEARCH_MODEL_UPDATER_METRICS_PORT   = 8015<br/>
> DEEPSEARCH_EMBEDDING_METRICS_PORT       = 8016<br/>
> CONTAINER_SUBNET                        = 192.168.2.128/26<br/>
> OMNI_FARM_HOST                          = HOST name for the Omniverse Farm Queue (example: my-omniverse-farm.my-company.com)<br/>
> OMNI_FARM_PORT                          = PORT for the Omniverse Farm Queue (example: 8222)<br/>
> OMNI_FARM_USE_CACHE_SERVER              = 0<br/>
> FARM_WORKER_DISK_CACHE_SIZE_LIMIT       = 32212254720<br/>
> N_PROJECTION_WORKERS                    = 1 (Determines how many workers to spawn to process projection requests, covert CLIP embedding vectors to a lower dimensional space using some dimensionality reduction methods)<br/>
> N_INFERENCE_WORKERS                     = 2 (how many workers to spawn to process inference requests)<br/>
> CACHE_SERVICE_DISK_CACHE_SIZE_LIMIT     = 32212254720 (in byte roughly 30 GB)<br/>
> PLUGIN_CONFIG                           = ./plugin.config.yaml<br/>


Depending on which backend type you use, set the variable ```SEARCH_BACKEND_TYPE``` accordingly:<br/>
```properties
Elastic Search:    `SEARCH_BACKEND_TYPE=es_index`
OpenSearch:        `SEARCH_BACKEND_TYPE=os_index`
```
Plugin configuration<br/>

DeepSearch service is built as a collection of plugins, each of which does a specific job. These plugins can be optionally activated and deactivated by modifying the plugin.config.yaml file.<br/>

- thumbnail_generation - generation of thumbnails for the USD assets in Nucleus<br/>
- thumbnail_to_embedding - extraction of CLIP embeddings from thumbnails of files found in Nucleus<br/>
- rendering_to_embedding_ds2 - rendering USD assets from multiple views and extraction of CLIP embeddings from each view to better characterize the asset<br/>



# Appendix

## Enterprise Nucleus Server Readme

Source: nucleus-stack-2022.4.0+tag-2022.4.0-rc.1.gitlab.6522377.48333833</br>

Welcome to Enterprise Nucleus Server compose and configuration files! 

If you have not already, please ensure to read thru general overview 
and installation sections of Omniverse Nucleus Documentation at
http://docs.omniverse.nvidia.com/nucleus

### Notes

* `base_stack` directory contains the Base Nucleus Stack with all it's services
  and deployment tooling.

  * Note that there are two compose files - `nucleus-stack-no-ssl.yml` and 
    `nucleus-stack-ssl.yml` - in the base stack. One of them should only be used
    when standing up a stack with no SSL, and another when standing up a stack
    that SSL is to be used with. 

    For more information on SSL, refer to the `.env` file and 
    http://docs.omniverse.nvidia.com/nucleus/ssl

  * Additionally, this dir contains data upgrade and data verification stacks
    (`nucleus-upgrade-db.yml` and  `nucleus-verify-db.yml`) that can be 
    run as utilities to upgrade and verify Nucleus's internal DB as required.

    Launch them in foreground with your .env file, and observe the results. 

    Note: verification should be run *after* upgrade - in other words, 
    verifier inclided in this version can only verify data of this, and not
    other, versions of Nucleus. 

    IMPORTANT: Nucleus Stack must be stopped to perform verification and/or
    IMPORTANT: upgrades.

* `navigator` directory contains standalone Navigator stack. This allows you 
  to stand up Omniverse Navigator as a separate service in your environment if 
  you so desire. 

  Standalone Navigator instances allow users to connect to any number 
  of Enterprise Nucleus servers, and manage their content in one place. 

* `sso` directory contains the SSO Gateway Stack, required for Single Sign On integration

* `ssl` directory contains a sample section of NGINX config file as an example
  of a working Ingress Router setup required for SSL. 

  For more information, see SSL docs at
  http://docs.omniverse.nvidia.com/nucleus/ssl