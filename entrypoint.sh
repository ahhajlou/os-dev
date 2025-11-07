#!/bin/bash

/opt/build-dependencies.sh
if [ ! "$?" -eq 0 ]; then
    echo -e "\033[1;31mFailed to install dependencies\033[0m"
    exit 1
fi

exec /bin/bash