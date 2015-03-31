#!bin/bash

# Make sure webapp be there in Graphite's log directory,
# if external volume is used; otherwise, Graphite won't start.
mkdir -p /opt/graphite/storage/log/webapp

/usr/bin/supervisord
