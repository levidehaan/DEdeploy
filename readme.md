Docker Enterprise Tools
=======================

Tools for Docker in the Enterprise


This is a first commit of some tools used to build large data center installs of docker and tools like mesos/marathon


What this project is going to cover
------------------------------------


Docker Enterprise tools are a companion set of tools for deploying Enterprise clusters/projects using a tool that simplifies deployment.
This project is meant to cover deployment from bare metal up.



What is left to do:
-------------------

Immediate:
* Make networking config easier for switching between testing (virtualbox) && prod
* setup littlechef book for base docker
* setup littlechef book for base cluster setup (mesos/marathon/consul/registrator||mesos/marathon/kubernetes/cadvisor||etc..)
* add to littlechef + fabfile to read from dhcp client list from dnsmasq to populate ip list for servers to run cookbooks on.


Coming:
* Base monitoring install (deployed with docker, as plugin, i.e. can be added later)
* Add Chef more chef scripts
* Add customized dockerfiles for mesos/marathon, kafka, hadoop, sparksql, etc..
* Add cluster deploy scripts to fabric file, using fabrics parallel functionality