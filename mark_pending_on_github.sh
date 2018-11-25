#!/usr/bin/env bash
source ${TRAVIS_BUILD_DIR}/set_environmental_variables.sh
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s) && echo "=== BUILDING COMMIT: $COMMIT_MESSAGE ==="
source ${TEST_REPO_PATH}/update-status.sh --sha=${SHA} \
   --repo=mikepsinn/${REPO_TO_TEST} \
   --status=pending \
   --message="Testing $COMMIT_MESSAGE on Travis..." \
   --context="${TRAVIS_TEST_GROUP}" \
   --url=https://travis-ci.org/${TRAVIS_REPO_SLUG}/builds/${TRAVIS_BUILD_ID}