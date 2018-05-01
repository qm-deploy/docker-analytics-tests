#!/usr/bin/env bash
export TEST_REPO_PATH="$PWD"
export QM_DOCKER_PATH="$PWD/QM-Docker"
echo "HOSTNAME is ${HOSTNAME} and QM_DOCKER_PATH is $QM_DOCKER_PATH"
export TEST_SUITE=Analytics

./update-status.sh --sha=${TRAVIS_COMMIT_MESSAGE} \
   --repo=mikepsinn/QM-Docker \
   --status=pending \
   --message="Starting ${TEST_SUITE} tests" \
   --context=${TEST_SUITE} \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}

#### halt script on error
#set -xe

echo '##### Print docker version'
docker --version

echo '##### Print environment'
env | sort

echo "Checking out revision ${TRAVIS_COMMIT_MESSAGE}"
mkdir QM-Docker
cd QM-Docker
git init
git remote add origin https://${GITHUB_ACCESS_TOKEN}@github.com/mikepsinn/QM-Docker.git
git fetch --depth 1 origin ${TRAVIS_COMMIT_MESSAGE}
git checkout FETCH_HEAD

ls

export CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
export TEST_CLEARDB_DATABASE_URL_READONLY=mysql://root:root@mysql/${TEST_SUITE}?reconnect=true
mkdir ${QM_DOCKER_PATH}/phpunit

echo "Copying slim/envs/circleci.env to .env"
cp ${QM_DOCKER_PATH}/slim/envs/circleci.env ${QM_DOCKER_PATH}/.env
cp ${TEST_REPO_PATH}/test.env ${QM_DOCKER_PATH}/laradock/.env

cd ${QM_DOCKER_PATH}/laradock
docker-compose up -d mysql workspace mongo
docker-compose exec --user=laradock workspace bash -c "cd slim && composer install"

if [ ${TEST_SUITE} = "Laravel" ]
 then
    docker-compose exec --user=laradock workspace bash -c "cd laravel && composer install"
    docker-compose exec --user=laradock workspace bash -c "slim/vendor/phpunit/phpunit/phpunit --configuration laravel/phpunit.xml --stop-on-error --stop-on-failure --log-junit phpunit/${TEST_SUITE}.xml"
 else
    docker-compose exec --user=laradock workspace bash -c "slim/vendor/phpunit/phpunit/phpunit --stop-on-error --stop-on-failure --configuration slim/tests/phpunit.xml --log-junit phpunit/${TEST_SUITE}.xml slim/tests/Api/${TEST_SUITE}"
fi

./update-status.sh --sha=${TRAVIS_COMMIT_MESSAGE} \
   --repo=mikepsinn/QM-Docker \
   --status=success \
   --message="${TEST_SUITE} tests successful!" \
   --context=${TEST_SUITE} \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}