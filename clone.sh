#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
echo "Checking out revision ${SHA}"
if [[ ! -d "${REPO_TO_TEST}" ]];
    then
        echo "${REPO_TO_TEST} repo not found so cloning" && set -x
        git clone -b ${BRANCH} --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/${REPO_TO_TEST}.git ${REPO_TO_TEST};
fi
if [[ ! -d "${REPO_TO_TEST}" ]];
    then
        echo "Clone of ${BRANCH} branch failed so cloning develop branch" && set -x;
        git clone -b develop --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/${REPO_TO_TEST}.git ${REPO_TO_TEST};
fi
set -x
cd ${REPO_TO_TEST} && git stash && git pull origin ${BRANCH}
git submodule update --init --recursive
chmod +x tests/travis/*.sh
