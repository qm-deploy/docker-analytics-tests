#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/${REPO_TO_TEST}"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
# Must use TRAVIS_TEST_GROUP instead of TEST_SUITE variable because the ambiguity causes problems
if [ -z "$TRAVIS_TEST_GROUP" ];
    then
        export TRAVIS_TEST_GROUP=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f1 -d#)
    else
       echo "Using TRAVIS_TEST_GROUP ENV: $TRAVIS_TEST_GROUP"
fi
export BRANCH=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f2 -d#)
export SHA=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f3 -d#)
export CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export MONGO_DB_CONNECTION=mongodb://127.0.0.1:27017