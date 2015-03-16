#!/bin/bash

# Author: Jose Antonio Quevedo <joseantonio.quevedo@gmail.com>
# GPLv2

GITHUB_USER=$1

for repo in $(curl https://github.com/${GITHUB_USER}/ 2>/dev/null | grep codeRepository | cut -d \" -f 2 | cut -d / -f 3);do

    #echo "He leido GITHUB_USER: "${GITHUB_USER}" and repo: "${repo}
    echo "GITHUB_USER: "${GITHUB_USER}". Repo: "${repo}
    if [ -d ${repo}/.git/ ]; then
	cd ${repo} && git pull
	cd - >/dev/null
    else
	git clone git@github.com:${GITHUB_USER}/${repo}.git;	
    fi


done
