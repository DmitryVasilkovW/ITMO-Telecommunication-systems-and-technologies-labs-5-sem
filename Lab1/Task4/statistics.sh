#!/bin/bash

for i in {1..3}; do
	echo "current time: $(date)"
	echo "Interface bond007:"
	grep bond007 /proc/net/dev
	sleep 3
done
