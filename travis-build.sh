#!/usr/bin/env bash

#### halt script on error
set -xe

echo '##### Print docker version'
docker --version

echo '##### Print environment'
env | sort

git config core.sparsecheckout # timeout=10

set +x

echo "Fetching changes from the remote Git repository"
git config remote.origin.url https://${GITHUB_TOKEN}@github.com/mikepsinn/QM-Docker.git # timeout=10
echo "Fetching upstream changes from QM-Docker"
git --version
git fetch --no-tags --progress https://${GITHUB_TOKEN}@github.com/mikepsinn/QM-Docker.git +refs/heads/*:refs/remotes/origin/* --prune --depth=20
git show-ref --tags -d
echo "Checking out Revision ${TRAVIS_COMMIT_MESSAGE}"
git config core.sparsecheckout # timeout=10
git checkout -f ${TRAVIS_COMMIT_MESSAGE}

cd QM-Docker && bash slim/scripts/phpunit_tests_docker.sh