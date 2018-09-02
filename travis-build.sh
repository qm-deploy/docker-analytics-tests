#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
if [ -z "$TEST_SUITE" ];
    then
        export TEST_SUITE=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f1 -d#)
    else
       echo "Using TEST_SUITE ENV: $TEST_SUITE"
fi
export BRANCH=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f2 -d#)
export SHA=$(echo ${TRAVIS_COMMIT_MESSAGE} | cut -f3 -d#)

#### halt script on error
#set -xe
echo '##### Print environment'
env | sort
echo "Checking out revision ${SHA}"
if [ ! -d "QM-Docker" ]; then echo "Repo not found so cloning" && git clone -b ${BRANCH} --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/QM-Docker.git QM-Docker; fi
cd QM-Docker && git stash && git pull origin ${BRANCH} && git submodule update --init --recursive
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s) && echo "=== BUILDING COMMIT: $COMMIT_MESSAGE ==="
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=pending \
   --message="Testing $COMMIT_MESSAGE on Travis..." \
   --context="${TEST_SUITE}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}
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
sudo chown -R ${USER} ~/.composer/
cd slim && composer install --prefer-dist
cd ${QM_DOCKER_PATH}/public.built && composer install --prefer-dist
WP_LOAD=${QM_DOCKER_PATH}/public.built/wp/wp-load.php
if [ ! -e "${WP_LOAD}" ]; then
    echo "${WP_LOAD} does not exist"
    exit 1;
else
    echo "${WP_LOAD} exists"
fi
cd ${QM_DOCKER_PATH}
set -x
case "$TEST_SUITE" in
    Laravel)  export APP_LOG_LEVEL=INFO && export LARAVEL=1
        cd laravel && composer install --prefer-dist
        ${QM_DOCKER_PATH}/slim/vendor/phpunit/phpunit/phpunit --configuration  ${QM_DOCKER_PATH}/laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit ${QM_DOCKER_PATH}/phpunit/${TEST_SUITE}.xml
        ;;
    AppSettingsModel)  export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/AppSettings
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Model
        ;;
    ModelConnectors)   export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Model
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Connectors
        ;;
    ConnectorsControllers)   export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Connectors
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Controllers
        ;;
    AppSettingsControllers)   export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/AppSettings
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Controllers
        ;;
    AnalyticsTasks)   export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Analytics
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Tasks
        ;;
    MeasurementsReminders)   export APP_LOG_LEVEL=ERROR
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Measurements
        slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/Reminders
        ;;
    *) slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}
       ;;
esac
