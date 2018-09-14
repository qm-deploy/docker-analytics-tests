#!/usr/bin/env bash
echo '##### Print environment'
env | sort
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
export TEST_SUITE=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f1 -d#)
export BRANCH=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f2 -d#)
export SHA=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f3 -d#)
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=pending \
   --message="Running ${TEST_SUITE} tests on Travis..." \
   --context="${TEST_SUITE}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}
#### halt script on error
#set -xe
echo "Checking out revision ${SHA}"
if [ ! -d "QM-Docker" ]; then echo "Repo not found so cloning"  && git clone -b ${BRANCH} --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/QM-Docker.git QM-Docker; fi
cd QM-Docker && git stash && git pull origin ${BRANCH}
ls
export CLEARDB_DATABASE_URL=${JAWSDB_URL}
export CLEARDB_DATABASE_URL_READONLY=${JAWSDB_URL}
export TEST_CLEARDB_DATABASE_URL=${JAWSDB_URL}
export TEST_CLEARDB_DATABASE_URL_READONLY=${JAWSDB_URL}
export MONGO_DB_CONNECTION=${MONGODB_URI}
ENV_COMMAND="export TEST_CLEARDB_DATABASE_URL=${TEST_CLEARDB_DATABASE_URL} && export TEST_CLEARDB_DATABASE_URL_READONLY=${TEST_CLEARDB_DATABASE_URL_READONLY} && export MONGO_DB_CONNECTION=${MONGO_DB_CONNECTION} && "
mkdir ${QM_DOCKER_PATH}/phpunit || true
echo "Copying slim/envs/circleci.env to .env"
cp ${QM_DOCKER_PATH}/slim/envs/circleci.env ${QM_DOCKER_PATH}/.env
cd slim && composer install --prefer-dist --optimize-autoloader
cd ${QM_DOCKER_PATH}
if [ ${TEST_SUITE} = "Laravel" ]
 then
    cd laravel && composer install --prefer-dist --optimize-autoloader
    slim/vendor/phpunit/phpunit/phpunit --configuration laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit phpunit/${TEST_SUITE}.xml
 else
    if [ ${TEST_SUITE} = "AppSettingsModel" ]  # Don't have to install mongo extension twice if we run these 2 fast tests together
     then
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/AppSettings
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Model
     else
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}
    fi
fi
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=success \
   --message="${TEST_SUITE} tests successful on Travis!" \
   --context="${TEST_SUITE}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}