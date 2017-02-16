#!/bin/sh

date

set -e
set -u

# load SSH key for accessing github
if [ -e ~/.ssh/id_rsa_echronos_ci ]; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa_echronos_ci
fi

# update to latest version of main branch to ensure that we run the latest version of the main update functionality
git fetch origin main
git checkout --force main
git reset --hard origin/main

# run main update functionality
sh ./update_2nd_stage.sh

if [ -e ~/.ssh/id_rsa_echronos_ci ]; then
    ssh-agent -k
fi
