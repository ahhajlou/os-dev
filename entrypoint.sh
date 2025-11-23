#!/bin/bash

/opt/build-dependencies.sh
if [ ! "$?" -eq 0 ]; then
    echo -e "\033[1;31mFailed to install dependencies\033[0m"
    exit 1
fi


# If arguments were passed, execute them instead of the default bash shell
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    exec /bin/bash
fi