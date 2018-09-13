#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
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