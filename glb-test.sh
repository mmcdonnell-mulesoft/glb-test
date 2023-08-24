#!/bin/bash

URI=${1}

if [ -z "${URI}" ]; then
    echo "Need URI to spam. Needs to be a GET as well."
    echo "  Example: ${0} http://mm-ping-server.us-e2.cloudhub.io/api/ping?volume=LOUD"
    exit 1
fi;

FAILBIT=-1
RECOVERBIT=-1

CMD="curl -kI -X GET ${URI} 2>/dev/null | head -n 1 | cut -d' ' -f2"

while [ ${RECOVERBIT} -lt 0 ] ; do
    # Execute CURL
    CODE=$(curl -kI -X GET ${URI} 2>/dev/null | head -n 1 | cut -d' ' -f2)
    FQDN=$(echo "${URI}" | awk -F/ '{print $3}')
    CNAME=$(nslookup ${FQDN} | grep canonical | awk -F= '{gsub(/ /,""); print $2}')
    # If its a failure:
    if [ ${CODE} -gt 299 ]; then
        # If its first fail - failbit will == -1
        if [ ${FAILBIT} -lt 1 ]; then
            echo "" # Insert new line after dots
            echo "Failed - Waiting to come back online"
            SECONDS=0
            FAILBIT=1
        fi
    else
        if [ ${FAILBIT} -lt 0 ]; then
            echo "Request to ${FQDN} is healthy. (${CODE})"
            echo "${FQDN} is pointing to ${CNAME}"
            FAILBIT=0
        elif [ ${FAILBIT} -gt 0 ]; then
            echo ""
            echo "Request to ${FQDN} is healthy again. (${CODE})"
            echo "${FQDN} is pointing to ${CNAME} now after failover"
            FAILBIT=0
            RECOVERBIT=1
            DURATION=$SECONDS
        fi;
    fi;
    if [ ${RECOVERBIT} == 1 ]; then
        echo "Failover Complete."
        break
    else
        echo -n "." && sleep 5;
    fi;
done;

# Display the time difference in an echo statement
echo "Failover took $((${DURATION} / 60)) minutes and $((${DURATION} % 60)) seconds elapsed."