#!/bin/bash
# Install python git project requirements
echo "---- Installing git python web application project requirements ----"
#pip install -r /var/www/www/requirements.txt
pip install flask cherrypy
echo "---- Starting CherryPy Server ----"
/usr/bin/python /var/www/www/server.py > /dev/null 2>&1 &
echo "---- past server.py ----"