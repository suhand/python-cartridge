#!/bin/bash
/usr/local/bin/metadata_svc_bugfix.sh
/root/bin/init.sh > /tmp/init.log &
/usr/local/bin/pythonscript.sh > /tmp/pythonscript.log
