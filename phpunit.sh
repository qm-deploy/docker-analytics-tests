#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
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