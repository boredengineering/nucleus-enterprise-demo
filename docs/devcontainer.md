# Dev Container 

The Devcontainer will not work as is because it need some work on the bind volumes and paths

TODO:
- Create the vscode configuration for the dev container
- Create a Github template

Install the Session Manager plugin on Ubuntu

```properties
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->
<!-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -->

Notes from

https://medium.com/about-developer-blog/how-to-use-aws-cli-and-ssm-with-docker-f14d3db9719c

Create your own docker image with SSM

```cat Dockerfile```

```dockerfile
FROM amazon/aws-cli
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" && \
    yum install -y ./session-manager-plugin.rpm
```

```docker build . -t awscli-local```

After the image is built, you need to edit your .zshrc file.

```cat ~/.zshrc```

```text
...
# you can do it as an alias
alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $PWD:/aws awscli-local'
# or a function
aws () {
    docker run --rm -it -v ~/.aws:/root/.aws -v $PWD:/aws awscli-local "$@"
}
...
```

