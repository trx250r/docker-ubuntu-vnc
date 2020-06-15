FROM ubuntu:20.04
MAINTAINER Marco Pantaleoni <marco.pantaleoni@gmail.com>

RUN echo "America/Chicago" > /etc/timezone
# RUN sudo ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime

RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends apt-utils tzdata

RUN dpkg-reconfigure -f noninteractive tzdata

# Install packages
RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends wget curl rsync netcat mg vim bzip2 zip unzip && \
    apt-get install -y --no-install-recommends libx11-6 libxcb1 libxau6 && \
    apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils && \
    apt-get install -y --no-install-recommends xfonts-base xfonts-75dpi xfonts-100dpi && \
    apt-get install -y --no-install-recommends python3 python3-pip python3-dev && \
    apt-get install -y --no-install-recommends libssl-dev && \
    apt-get install -y --no-install-recommends net-tools dnsutils iputils-ping traceroute && \
    apt-get install -y --no-install-recommends iptables autocutsel openssh-client openssh-server && \
    apt-get install -y --no-install-recommends nodejs npm && \
    apt-get install -y --no-install-recommends firefox && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/

RUN mkdir -p /root/.vnc
COPY xstartup /root/.vnc/
RUN chmod a+x /root/.vnc/xstartup
RUN touch /root/.vnc/passwd
RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd" > /root/.vnc/passwd
RUN chmod 400 /root/.vnc/passwd
RUN chmod go-rwx /root/.vnc
RUN touch /root/.Xauthority

COPY start-vncserver.sh /root/
RUN chmod a+x /root/start-vncserver.sh

RUN echo "mycontainer" > /etc/hostname
RUN echo "127.0.0.1	localhost" > /etc/hosts
RUN echo "127.0.0.1	mycontainer" >> /etc/hosts

COPY ssh.tar.gz /root/
RUN gunzip /root/ssh.tar.gz
RUN tar -xvf /root/ssh.tar
COPY mozilla.tar.gz /root/
RUN gunzip /root/mozilla.tar.gz
RUN tar -xvf /root/mozilla.tar

EXPOSE 5901
ENV USER root
CMD [ "/root/start-vncserver.sh" ]
