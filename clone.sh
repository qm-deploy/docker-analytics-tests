#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
echo "Checking out revision ${SHA}"
if [ ! -d "QM-Docker" ]; then echo "Repo not found so cloning" && git clone -b ${BRANCH} --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/QM-Docker.git QM-Docker; fi
if [ ! -d "QM-Docker" ]; then echo "Clone of ${BRANCH} branch failed so cloning develop branch" && git clone -b develop --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/QM-Docker.git QM-Docker; fi
cd QM-Docker && git stash && git pull origin ${BRANCH} && git submodule update --init --recursive