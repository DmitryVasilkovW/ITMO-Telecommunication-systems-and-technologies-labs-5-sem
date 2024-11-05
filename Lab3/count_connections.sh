#!/bin/bash

PORT=${1:-22}

netstat -tn | grep ":$PORT" | awk '{print $5}' | cut -d':' -f1 | sort | uniq -c | sort -nr
