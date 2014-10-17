#!/bin/bash

# wait until the git repo to be cloned to /var/www/www/ directory
while [ ! -f /var/www/www/requirements.txt ]
do
  echo "---- git repo is not cloned to /var/www/www/ yet, going to sleep, will recheck in 2 seconds ----"
  sleep 2
done

# Install python git project requirements
echo "------------------ Installing git python web application project requirements ------------------"

# retrieve python project specific dependencies from the project requirements.txt file
pip install -r /var/www/www/requirements.txt

# Start CherryPy server on specified port
# e.g.: port 5000
# 		to work in port 5000 you have to modify Docker file exposing port 5000 and
#		update the cartridge configuration accordingly http port -> 5000 and
#		modify server.py server.socket_port -> 5000
echo "----------------------------------- Starting CherryPy Server -----------------------------------"
python /var/www/www/server.py > /tmp/server.log 2>&1 &
echo "--------------- CherryPy server started... See /tmp/server.log for more details ----------------"