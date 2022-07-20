#!/bin/bash

# Everything in cleanup will be executed when this wrapper script is exited
# For example, on systemctl stop example.service or on service restart.
# In this example, the first portion kills all children of this script (our example script)
# second portion deletes the lock file for our example script

CLEANUP="kill $(jobs -p) ; rm /var/tmp/example-script.lock"

trap $CLEANUP EXIT

OPTIONS="-s -a -m -p -l -e"

# Launch our example script/target.  
/path/to/example-script.sh $OPTIONS &

# Set PID variable to our running script
PID=$!

# Let systemd know our service is up and running
/bin/systemd-notify --ready

# Main Loop
while(true); do
    # Presume everything is OK
    FAIL=0

    # kill with -0 will not send any signal to the process but error checking is still performed.
    # this includes checking for the existence of the PID
    kill -0 $PID

    # Did our last command execute successfully? 
    # If our example script died in the background somehow, then kill -0 $PID will return 1
    if [[ $? -ne 0 ]]; then FAIL=1; fi

    # The reason I split fail into its own variable to check here
    # Is in case there are multiple fail-states - we can check each of them above
    # and then send systemd watchdog an "everythings still good" heartbeat/ping
    # if nothing broke
    if [[ $FAIL -eq 0 ]]; then /bin/systemd-notify WATCHDOG=1; fi

    # sleeeeeeep
    sleep 1
done