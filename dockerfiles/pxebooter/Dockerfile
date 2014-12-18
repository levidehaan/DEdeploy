FROM ubuntu:14.04

RUN apt-get -q update; apt-get -qy upgrade

RUN apt-get -qy install dnsmasq wget iptables

RUN mkdir /tftp; mkdir /tftp/boot; mkdir /tftp/ubuntu; mkdir /tftp/pxelinux.cfg

ADD https://raw.github.com/jpetazzo/pipework/master/pipework /root/pipework

ADD cmd.this /root/cmd.this

ADD installfiles /tftp/

ADD isomount /tftp/ubuntu

ADD dnsmasq.conf /etc/dnsmasq.conf

RUN chmod +x /root/pipework; chmod +x /root/cmd.this

VOLUME ["/data"]

CMD ["/root/cmd.this"]