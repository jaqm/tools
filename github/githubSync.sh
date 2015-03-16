#!/bin/bash

# Author: Jose Antonio Quevedo <joseantonio.quevedo@gmail.com>
# GPLv2

#set -x

GITHUB_USER=$1

# Ref: https://developer.github.com/v3/repos/
for repo in $(curl "https://api.github.com/users/${GITHUB_USER}/repos?type=owner" 2>/dev/null | grep \"name\" | cut -d \" -f 4);do

    echo "Github_USER: "${GITHUB_USER}". Repo: "${repo}
    if [ -d ${repo}/.git/ ]; then
	cd ${repo} && git pull
	cd - >/dev/null
    else
	git clone git@github.com:${GITHUB_USER}/${repo}.git;	
    fi


done
