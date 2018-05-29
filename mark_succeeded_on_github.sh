#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
export TEST_SUITE=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f1 -d#)
export BRANCH=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f2 -d#)
export SHA=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f3 -d#)
cd ${QM_DOCKER_PATH} && COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s) && echo "=== $COMMIT_MESSAGE tests successful ===" && cd ..
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=success \
   --message="$COMMIT_MESSAGE tests successful on Travis!" \
   --context="${TEST_SUITE}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}