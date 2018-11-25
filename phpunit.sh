#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
run_test_suite () {
    export J_UNIT_FILE=${QM_DOCKER_PATH}/phpunit/$1.xml
    export TEST_SUITE=$1
    source ${QM_DOCKER_PATH}/tests/phpunit_tests.sh
}
cd ${QM_DOCKER_PATH}
set -x
rm ${QM_DOCKER_PATH}/phpunit/* || true
rm -rf ${QM_DOCKER_PATH}/phpunit/ || true
mkdir ${QM_DOCKER_PATH}/phpunit || true
if [[ $TRAVIS_TEST_GROUP = *"Laravel"* ]]; then
    export LARAVEL=1
    export TEST_SUITE=Laravel
    cd ${QM_DOCKER_PATH}/laravel && composer install --prefer-dist --optimize-autoloader
    source ${QM_DOCKER_PATH}/tests/phpunit_tests.sh
fi
if [[ $TRAVIS_TEST_GROUP = *"Analytics"* ]]; then run_test_suite Analytics; fi
if [[ $TRAVIS_TEST_GROUP = *"AppSettings"* ]]; then run_test_suite AppSettings; fi
if [[ $TRAVIS_TEST_GROUP = *"Connectors"* ]]; then run_test_suite Connectors; fi
if [[ $TRAVIS_TEST_GROUP = *"Controllers"* ]]; then run_test_suite Controllers; fi
if [[ $TRAVIS_TEST_GROUP = *"Measurements"* ]]; then run_test_suite Measurements; fi
if [[ $TRAVIS_TEST_GROUP = *"Model"* ]]; then run_test_suite Model; fi
if [[ $TRAVIS_TEST_GROUP = *"Tasks"* ]]; then run_test_suite Tasks; fi
echo "Done!"