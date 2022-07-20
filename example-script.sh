#!/bin/bash

echo "Received " $# "arguments."
echo "Supplied arguments are: " $*

touch /var/tmp/example-script.lock

while(true); do
    date -Is | tee /var/tmp/example-script.log
    sleep 1
done

