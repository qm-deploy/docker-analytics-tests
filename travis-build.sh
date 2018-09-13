#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
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
#### halt script on error

#echo '##### Print environment'
#env | sort
echo "Checking out revision ${SHA}"
if [ ! -d "QM-Docker" ]; then echo "Repo not found so cloning" && git clone -b ${BRANCH} --recurse-submodules --single-branch https://${GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/mikepsinn/QM-Docker.git QM-Docker; fi
cd QM-Docker && git stash && git pull origin ${BRANCH} && git submodule update --init --recursive
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s) && echo "=== BUILDING COMMIT: $COMMIT_MESSAGE ==="
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/QM-Docker \
   --status=pending \
   --message="Testing $COMMIT_MESSAGE on Travis..." \
   --context="${TRAVIS_TEST_GROUP}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}
ls

echo "Installing XHGUI..."
git clone https://github.com/perftools/xhgui.git ${QM_DOCKER_PATH}/public.built/xhgui
cd ${QM_DOCKER_PATH}/public.built/xhgui
composer install
set -x

export CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:@127.0.0.1/quantimodo_test?reconnect=true
export MONGO_DB_CONNECTION=mongodb://127.0.0.1:27017
ENV_COMMAND="export TEST_CLEARDB_DATABASE_URL=${TEST_CLEARDB_DATABASE_URL} && export TEST_CLEARDB_DATABASE_URL_READONLY=${TEST_CLEARDB_DATABASE_URL_READONLY} && export MONGO_DB_CONNECTION=${MONGO_DB_CONNECTION} && "
mkdir ${QM_DOCKER_PATH}/phpunit || true
echo "Copying ${QM_DOCKER_PATH}/slim/envs/circleci.env to .env"
cp ${QM_DOCKER_PATH}/slim/envs/circleci.env ${QM_DOCKER_PATH}/.env
sudo chown -R ${USER} ~/.composer/
cd ${QM_DOCKER_PATH}/slim && composer install --prefer-dist
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
rm ${QM_DOCKER_PATH}/phpunit/* || true
rm -rf ${QM_DOCKER_PATH}/phpunit/ || true
mkdir ${QM_DOCKER_PATH}/phpunit || true
case "$TRAVIS_TEST_GROUP" in
    Laravel)  export LARAVEL=1
        export TEST_SUITE=Laravel
        source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #cd laravel && composer install --prefer-dist
        #J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/${TEST_SUITE}.xml
        #${QM_DOCKER_PATH}/slim/vendor/phpunit/phpunit/phpunit --configuration  ${QM_DOCKER_PATH}/laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit ${J_UNIT_FILE}
        ;;
    AppSettingsModel)
        #J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Model.xml
        export TEST_SUITE=AppSettings && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/AppSettings.xml slim/tests/Api/AppSettings
        export TEST_SUITE=Model && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Model.xml slim/tests/Api/Model
        ;;
    ModelConnectors)
        J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Connectors.xml
        export TEST_SUITE=Model && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Model.xml slim/tests/Api/Model
        export TEST_SUITE=Connectors && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Connectors.xml slim/tests/Api/Connectors
        ;;
    ConnectorsControllers)
        J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Controllers.xml
        export TEST_SUITE=Connectors && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Connectors.xml slim/tests/Api/Connectors
        export TEST_SUITE=Controllers && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Controllers.xml slim/tests/Api/Controllers
        ;;
    AppSettingsControllers)
        J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Controllers.xml
        export TEST_SUITE=AppSettings
        echo "TEST_SUITE set to $TEST_SUITE"
        source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/AppSettings.xml slim/tests/Api/AppSettings
        export TEST_SUITE=Controllers && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Controllers.xml slim/tests/Api/Controllers
        ;;
    AnalyticsTasks)
        J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Tasks.xml
        export TEST_SUITE=Analytics && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Analytics.xml slim/tests/Api/Analytics
        export TEST_SUITE=Tasks && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Tasks.xml slim/tests/Api/Tasks
        ;;
    MeasurementsReminders)
        J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/Reminders.xml
        export TEST_SUITE=Measurements && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Measurements.xml slim/tests/Api/Measurements
        export TEST_SUITE=Reminders && source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/Reminders.xml slim/tests/Api/Reminders
        ;;
    *) J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/${TEST_SUITE}.xml
        source ${QM_DOCKER_PATH}/slim/scripts/phpunit_tests.sh
        #slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}
       ;;
esac
echo "done!"