#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
echo "Installing XHGUI..."
git clone https://github.com/perftools/xhgui.git ${QM_DOCKER_PATH}/public.built/xhgui
cd ${QM_DOCKER_PATH}/public.built/xhgui
composer install