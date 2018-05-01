#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
export TEST_SUITE=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f1 -d-)
export SHA=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f2 -d-)

source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=pending \
   --message="Starting ${TEST_SUITE} tests" \
   --context="Travis/${TEST_SUITE}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}

#### halt script on error
#set -xe

echo '##### Print docker version'
docker --version

echo '##### Print environment'
env | sort

echo "Checking out revision ${SHA}"
mkdir QM-Docker || true
cd QM-Docker
git init || true
git remote add origin https://${GITHUB_ACCESS_TOKEN}@github.com/mikepsinn/QM-Docker.git || true
#git fetch --depth 50 origin ${SHA}
#git checkout FETCH_HEAD
git checkout -f ${SHA}

ls

export CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export MONGO_DB_CONNECTION=mongodb://127.0.0.1:27017
ENV_COMMAND="export TEST_CLEARDB_DATABASE_URL=${TEST_CLEARDB_DATABASE_URL} && export TEST_CLEARDB_DATABASE_URL_READONLY=${TEST_CLEARDB_DATABASE_URL_READONLY} && export MONGO_DB_CONNECTION=${MONGO_DB_CONNECTION} && "
mkdir ${QM_DOCKER_PATH}/phpunit || true

echo "Copying slim/envs/circleci.env to .env"
cp ${QM_DOCKER_PATH}/slim/envs/circleci.env ${QM_DOCKER_PATH}/.env

cd slim && composer install --prefer-dist
cd ${QM_DOCKER_PATH}

if [ ${TEST_SUITE} = "Laravel" ]
 then
    cd laravel && composer install --prefer-dist
    slim/vendor/phpunit/phpunit/phpunit --configuration laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit phpunit/${TEST_SUITE}.xml
 else
    slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}
fi

source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=success \
   --message="${TEST_SUITE} tests successful!" \
   --context=${TEST_SUITE} \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}