# Notes about the Nucleus Enterprise Server

This doc is a brief overview of the changes necessary on ```nucleus-stack.env``` to make the jinja template that is used by Ansible ```nucleus-stack.env.j2```.

These changes are necessary because the Nucleus Enterprise server is being deployed using Docker Compose and it depends on a list of environment variables stored in ```nucleus-stack.env```.<br/>

First you must download the Nucleus Stack from the [Mvidia Application Hub](https://nvid.nvidia.com/dashboard/) then unpack it

Command to unpack

```terminal
tar -xzvf nucleus-stack-2022.1.0+tag-2022.1.0.gitlab.3983146.613004ac.tar.gz -C  nucleus-stack --strip-components=1
```

**Step 1** - Update nucleus-stack.env

With your preferred text editor, Update nucleus-stack.env

Uncomment Accept EULA
```ACCEPT_EULA=1```

Uncomment Security Reviewed
```SECURITY_REVIEWED=1```

Web UI Port - If setting up with SSL, we recommend changing from port 80 to port 8080 to avoid confusion with port 80 open on the Ingress Router
```WEB_PORT = 8080 ```

**ATTENTION** - NVIDIA recommends that you set this to 8080, this is also what the nginx.conf is configured to expect

```SERVER_IP_OR_HOST={{ base_stack_ip_or_host }}```

```SSL_INGRESS_HOST={{ domain }}```

```INSTANCE_NAME={{ instance_name }}```

**Step 2** - Pack Nucleus Stack

Rename the file ```nucleus-stack.env``` to ```nucleus-stack.env.j2```


Run the following to Pack into nucleus-stack.tar.gz

```terminal
tar -czvf nucleus-stack.tar.gz nucleus-stack
```

<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->

Attention !!! this deployment only includes the SSL not the SSO.<br/>

Nucleus Enterprise is being deployed using Docker Compose and dependent on a list of environment variables stored in ```nucleus-stack.env```<br/>

For the Version 2022.4.0+tag-2022.4.0-rc.1.gitlab.6522377.48333833

On ```nucleus-stack.env``` we must modify the following variables:<br/>

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


Terraform Template, these variables will be used by Ansible:

> region:                       "${region}"<br/>
> profile_name:                 "${profile}"<br/>
> bucketname:                   "${Bucketname}"<br/>
> domain:                       "${domain}"<br/>
> instance_name:                "${instance_name}"<br/>
> base_stack_ip_or_host:        "${NucleusServerPrivateDnsName}"<br/>
> omni_farm_host:               "${omni_farm_host}"<br/>
> auth_root_of_trust_pub:       "${auth_root_of_trust_pub}"<br/>
> discovery_registration_token: "${discovery_registration_token}"<br/>
> search_backend_type:          "${search_backend_type}"<br/>
> search_backend_host:          "${search_backend_host}"<br/>
> server_ip_or_host:            "${server_ip_or_host}"<br/>



<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->

For the version 2023.2.5+tag-2023.2.5.gitlab.17901596.a6feb798

TODO create a cariable for

MASTER_PASSWORD=123456

SERVICE_PASSWORD=123456

