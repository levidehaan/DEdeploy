FROM ubuntu:14.04

RUN apt-get -q update

RUN apt-get -qy install dnsmasq wget iptables

RUN mkdir /tftp; mkdir /tftp/boot; mkdir /tftp/ubuntu; mkdir /tftp/pxelinux.cfg

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /root/pipework

RUN chmod +x /root/pipework

ADD cmd.this /root/cmd.this

ADD pxecfg.default /tftp/pxelinux.cfg/default

ADD installfiles /tftp/boot/

ADD isomount /tfptp/ubuntu

VOLUME ["/data"]

CMD cmd.this