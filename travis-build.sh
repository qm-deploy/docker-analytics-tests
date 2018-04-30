#!/usr/bin/env bash

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
bash slim/scripts/phpunit_tests_docker.sh