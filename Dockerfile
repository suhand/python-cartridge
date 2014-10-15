FROM		ubuntu:12.04
MAINTAINER 	Suhan Dharmasuriya "suhanr@wso2.com"

RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get -y update --fix-missing
RUN apt-get install -y dialog tree
RUN apt-get install -y apt-utils g++ 
RUN apt-get install -y libtool wget
RUN apt-get install -q -y zip unzip
RUN apt-get install -q -y vim

WORKDIR /opt/

RUN apt-get install -y openssh-server
RUN echo 'root:pass' |chpasswd
RUN mkdir -p /var/run/sshd

##################################
# Install Python Dependencies
##################################
# Install Python dependencies for Flask/CherryPy web application - Sample 1
RUN apt-get install -y build-essential python-dev python-pip python-virtualenv libpq-dev

# Install Python dependencies for Django CMS system - Sample 2
#RUN apt-get install -y libjpeg-dev libfreetype6-dev zlib1g-dev
#RUN apt-get install -y sqlite3 libsqlite3-dev
#RUN apt-get install -y bzip2 libbz2-dev

RUN pip install flask
RUN pip install cherrypy

# Clone sample Python web application 2 samples
#RUN apt-get install -y git
#WORKDIR /opt/
#RUN git clone https://github.com/suhand/python-cartridge-flask-demo.git
#RUN git clone https://github.com/divio/django-cms.git

##################################
# Install Stratos Cartridge Agent
##################################

# java 1.7
ADD packs/jdk-7u7-linux-x64.tar.gz /opt/
RUN ln -s /opt/jdk1.7.0_07 /opt/java
WORKDIR /mnt/
ADD packs/apache-stratos-cartridge-agent-4.0.0.zip /mnt/
RUN unzip -q apache-stratos-cartridge-agent-4.0.0.zip
RUN rm apache-stratos-cartridge-agent-4.0.0.zip
RUN mkdir -p /mnt/apache-stratos-cartridge-agent-4.0.0/payload

##################################
# Copy ActiveMQ dependencies
##################################
ADD packs/activemq/activemq-broker-5.10.0.jar /mnt/apache-stratos-cartridge-agent-4.0.0/lib/activemq-broker-5.10.0.jar
ADD packs/activemq/activemq-client-5.10.0.jar /mnt/apache-stratos-cartridge-agent-4.0.0/lib/activemq-client-5.10.0.jar
ADD packs/activemq/geronimo-j2ee-management_1.1_spec-1.0.1.jar /mnt/apache-stratos-cartridge-agent-4.0.0/lib/geronimo-j2ee-management_1.1_spec-1.0.1.jar
ADD packs/activemq/geronimo-jms_1.1_spec-1.1.1.jar /mnt/apache-stratos-cartridge-agent-4.0.0/lib/geronimo-jms_1.1_spec-1.1.1.jar
ADD packs/activemq/hawtbuf-1.10.jar /mnt/apache-stratos-cartridge-agent-4.0.0/lib/hawtbuf-1.10.jar

# setup bootup scripts
RUN mkdir /root/bin
ADD init.sh /root/bin/
RUN chmod +x /root/bin/init.sh
ADD stratos_sendinfo.rb /usr/lib/ruby/1.8/facter/
ADD metadata_svc_bugfix.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/metadata_svc_bugfix.sh
ADD run_scripts.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run_scripts.sh
ADD pythonscript.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/pythonscript.sh

# workaround for host entries
RUN mkdir p - /root/lib
RUN cp /lib/x86_64-linux-gnu/libnss_files.so.2 /root/lib
RUN perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /root/lib/libnss_files.so.2
RUN cp /etc/hosts /tmp/hosts
ENV LD_LIBRARY_PATH /root/lib
RUN locale-gen en_US.UTF-8

EXPOSE 22
EXPOSE 80
EXPOSE 8101

ENTRYPOINT /usr/local/bin/run_scripts.sh | /usr/sbin/sshd -D


