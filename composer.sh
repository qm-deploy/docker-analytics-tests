#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
echo "Copying ${QM_DOCKER_PATH}/configs/envs/testing.env to .env"
cp ${QM_DOCKER_PATH}/configs/envs/testing.env ${QM_DOCKER_PATH}/.env
sudo chown -R ${USER} ~/.composer/

if [[ ${REPO_TO_TEST} != "QM-Docker" ]]; then
    cd ${QM_DOCKER_PATH} && composer install --prefer-dist --optimize-autoloader
else
    cd ${QM_DOCKER_PATH}/slim && composer install --prefer-dist --optimize-autoloader
    cd ${QM_DOCKER_PATH}/public.built && composer install --prefer-dist --optimize-autoloader
    WP_LOAD=${QM_DOCKER_PATH}/public.built/wp/wp-load.php
    if [[ ! -e "${WP_LOAD}" ]]; then
        echo "${WP_LOAD} does not exist"
        exit 1;
    else
        echo "${WP_LOAD} exists"
    fi
fi