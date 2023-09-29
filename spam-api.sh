#!/bin/bash

URI=${1}
GREEN='\033[1;32m'
NC='\033[0m' # No Color
RED='\033[0;31m'

if [ -z "${URI}" ]; then
    echo "Need URI to spam. Needs to be a GET as well."
    echo "  Example: ${0} http://mm-ping-server.us-e2.cloudhub.io/api/ping?volume=LOUD"
    exit 1
fi;

while [ 1 ] ; do
    CODE=$(curl -I -X GET ${URI} 2>/dev/null | head -n 1 | cut -d$' ' -f2)
    if [ ${CODE} -gt 299 ]; then
    #     echo ""
    #     echo "Bad Code! '${CODE}'"
    #     exit 2
        echo -e -n "${RED}.${NC}"
    else
        echo -e -n "${GREEN}.${NC}"
    fi;
    sleep $(( $RANDOM % 5 ));
done;