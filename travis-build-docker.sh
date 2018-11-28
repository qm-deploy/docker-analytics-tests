#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/${REPO_TO_TEST}"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
export TEST_SUITE=Analytics
source ${TEST_REPO_PATH}/update-status.sh --sha=${TRAVIS_COMMIT_MESSAGE} \
   --repo=mikepsinn/${REPO_TO_TEST} \
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
echo "Checking out revision ${TRAVIS_COMMIT_MESSAGE}"
mkdir ${REPO_TO_TEST} || true
cd ${REPO_TO_TEST}
git init || true
git remote add origin https://${GITHUB_ACCESS_TOKEN}@github.com/mikepsinn/${REPO_TO_TEST}.git || true
git fetch --depth 1 origin ${TRAVIS_COMMIT_MESSAGE}
git checkout FETCH_HEAD
ls
export CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export MONGO_DB_CONNECTION=mongodb://127.0.0.1:27017
ENV_COMMAND="export TEST_CLEARDB_DATABASE_URL=${TEST_CLEARDB_DATABASE_URL} && export TEST_CLEARDB_DATABASE_URL_READONLY=${TEST_CLEARDB_DATABASE_URL_READONLY} && export MONGO_DB_CONNECTION=${MONGO_DB_CONNECTION} && "
mkdir ${QM_DOCKER_PATH}/phpunit || true
echo "Copying configs/envs/testing.env to .env"
cp ${QM_DOCKER_PATH}/configs/envs/testing.env ${QM_DOCKER_PATH}/.env
cp ${TEST_REPO_PATH}/test.env ${QM_DOCKER_PATH}/laradock/.env
cd ${QM_DOCKER_PATH}/laradock
docker-compose build mysql
docker-compose up -d mysql workspace mongo
#echo "Waiting for mysql"
#until mysql -hmysql -P3306 -uroot -proot &> /dev/null
#do
#  printf "."
#  sleep 1
#done
docker-compose exec workspace bash -c "${ENV_COMMAND} cd slim && composer install --optimize-autoloader"
if [[ ${TEST_SUITE} = "Laravel" ]]
 then
    docker-compose exec workspace bash -c "${ENV_COMMAND} cd laravel && composer install --optimize-autoloader"
    docker-compose exec workspace bash -c "${ENV_COMMAND} vendor/phpunit/phpunit/phpunit --configuration laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit phpunit/${TEST_SUITE}.xml"
 else
    docker-compose exec workspace bash -c "${ENV_COMMAND} vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml tests/Api/${TEST_SUITE}"
fi
source ${TEST_REPO_PATH}/update-status.sh --sha=${TRAVIS_COMMIT_MESSAGE} \
   --repo=mikepsinn/${REPO_TO_TEST} \
   --status=success \
   --message="${TEST_SUITE} tests successful!" \
   --context=${TEST_SUITE} \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}