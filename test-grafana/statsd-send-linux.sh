#!/bin/bash

while :
do
	echo -n "example.statsd.counter.changed:$((((RANDOM %10)+1)*3))|c"| nc -w 1 -u localhost 8125
done
