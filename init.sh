#!/bin/bash
# --------------------------------------------------------------
#
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# 	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------


perl -pi -e 's:/etc/hosts:/tmp/hosts:g' /root/lib/libnss_files.so.2
export LD_LIBRARY_PATH=/root/lib
echo $LD_LIBRARY_PATH

MKDIR=`which mkdir`
UNZIP=`which unzip`
ECHO=`which echo`
FIND=`which find`
GREP=`which grep`
RM=`which rm`
XARGS=`which xargs`
SED=`which sed`
CUT=`which cut`
AWK=`which awk`
IFCONFIG=`which ifconfig`
HOSTNAME=`which hostname`
SLEEP=`which sleep`
TR=`which tr`
HEAD=`which head`
WGET=`which wget`
AGENT="agent"
PUPPETAGENT="${PUPPETD} ${AGENT}"

IP=`${IFCONFIG} eth0 | ${GREP} -e "inet addr" | ${AWK} '{print $2}' | ${CUT} -d ':' -f 2`

HOSTSFILE=/tmp/hosts
HOSTNAMEFILE=/etc/hostname

echo "test2"

is_public_ip_assigned() {

while true
do
   wget http://169.254.169.254/latest/meta-data/public-ipv4
   if [ ! -f public-ipv4 ]
    	then
      	echo "Public ipv4 file not found. Sleep and retry" >> $LOG
      	sleep 2;
      	continue;
    	else
      	echo "public-ipv4 file is available. Read value" >> $LOG
      	# Here means file is available. Read the file
      	read -r ip<public-ipv4;
      	echo "value is **[$ip]** " >> $LOG

      	if [ -z "$ip" ]
        	then
          	echo "File is empty. Retry...." >> $LOG
          	sleep 2
          	rm public-ipv4
          	continue
         	else
           	echo "public ip is assigned. value is [$ip]. Remove file" >> $LOG
           	rm public-ipv4
           	break
         	fi
    	fi
done
}


DATE=`date +%d%m%y%S`
RANDOMNUMBER="`${TR} -c -d 0-9 < /dev/urandom | ${HEAD} -c 4`${DATE}"

if [ ! -d /tmp/payload ]; then

	## Check whether the public ip is assigned
	is_public_ip_assigned

	echo "Public ip have assigned. Continue.." >> $LOG

	${MKDIR} -p /tmp/payload
	${WGET} http://169.254.169.254/latest/user-data -O /tmp/payload/launch-params
	cp /tmp/payload/launch-params /mnt/apache-stratos-cartridge-agent-4.0.0/payload/launch-params

	cd /tmp/payload
	SERVICE_NAME=`sed 's/,/\n/g' launch-params | grep SERVICE_NAME | cut -d "=" -f 2`
	DEPLOYMENT=`sed 's/,/\n/g' launch-params | grep DEPLOYMENT | cut -d "=" -f 2`
	INSTANCE_HOSTNAME=`sed 's/,/\n/g' launch-params | grep HOSTNAME | cut -d "=" -f 2`
	
	#get user parameters
	CEP_IP=`sed 's/,/\n/g' launch-params | grep CEP_IP | cut -d "=" -f 2`	
	CEP_PORT=`sed 's/,/\n/g' launch-params | grep CEP_PORT | cut -d "=" -f 2`
	MB_IP=`sed 's/,/\n/g' launch-params | grep MB_IP | cut -d "=" -f 2`
	MB_PORT=`sed 's/,/\n/g' launch-params | grep MB_PORT | cut -d "=" -f 2`
	
	#change ip and port of agent script 
	cd /mnt/apache-stratos-cartridge-agent-4.0.0/bin/
	sed -i "s/MB_IP/$MB_IP/g" stratos.sh		
	sed -i "s/MB_PORT/$MB_PORT/g" stratos.sh
	sed -i "s/CEP_IP/$CEP_IP/g" stratos.sh
	sed -i "s/CEP_PORT/$CEP_PORT/g" stratos.sh
	
	# change port and ip of jndi
	cd /mnt/apache-stratos-cartridge-agent-4.0.0/conf
	sed -i "s/MB_IP/$MB_IP/g" jndi.properties
	sed -i "s/MB_PORT/$MB_PORT/g" jndi.properties
	
	cd templates
	sed -i "s/MB_IP/$MB_IP/g" jndi.properties.template
	sed -i "s/MB_PORT/$MB_PORT/g" jndi.properties.template 
	
	#set java path parameter
	export JAVA_HOME=/opt/java
	export PATH=$PATH:$JAVA_HOME/bin

	#start stratos agent
	cd /mnt/apache-stratos-cartridge-agent-4.0.0/bin/;./stratos.sh > /tmp/agent.log


fi

# END

