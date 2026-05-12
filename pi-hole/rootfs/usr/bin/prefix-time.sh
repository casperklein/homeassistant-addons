#!/bin/bash

# Prefix each line from STDIN with the current date/time/timezone and write to PID 1 STDOUT (docker log)
while IFS= read -r line; do
	printf '%(%F %T %Z)T %s\n' -1 "$line" >>/proc/1/fd/1
done
