#!/usr/bin/env bash
export QM_DOCKER_PATH="$PWD" && export QM_IONIC_PATH="$PWD/public.built/ionic/Modo"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"

#### halt script on error
#set -xe

echo '##### Print docker version'
docker --version

echo '##### Print environment'
env | sort

git config core.sparsecheckout # timeout=10

echo "Fetching changes from the remote Git repository"
set +x
git config remote.origin.url https://${GITHUB_ACCESS_TOKEN}@github.com/mikepsinn/QM-Docker.git # timeout=10
set -x
echo "Fetching upstream changes from QM-Docker"
git --version
set +x
git fetch --no-tags --progress https://${GITHUB_ACCESS_TOKEN}@github.com/mikepsinn/QM-Docker.git +refs/heads/*:refs/remotes/origin/* --prune --depth=20
set -x
git show-ref --tags -d
echo "Checking out Revision ${TRAVIS_COMMIT_MESSAGE}"
git config core.sparsecheckout # timeout=10
git checkout -f ${TRAVIS_COMMIT_MESSAGE}
ls
cd QM-Docker || true
export TEST_SUITE=Analytics
export CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
mkdir ${QM_DOCKER_PATH}/phpunit

echo "Copying slim/envs/circleci.env to .env"
cp ${QM_DOCKER_PATH}/slim/envs/circleci.env ${QM_DOCKER_PATH}/.env
cp ${QM_DOCKER_PATH}/laradock/test.env ${QM_DOCKER_PATH}/laradock/.env
cd ${QM_DOCKER_PATH}/laradock
docker-compose up -d mysql workspace mongo
if [ ${TEST_SUITE} = "Laravel" ]
 then
    docker-compose exec --user=laradock workspace bash -c "cd laravel && composer install"
    docker-compose exec --user=laradock workspace bash -c "slim/vendor/phpunit/phpunit/phpunit --configuration laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit phpunit/${TEST_SUITE}.xml"
 else
    docker-compose exec --user=laradock workspace bash -c "slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}"
fi