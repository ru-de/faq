#!/bin/bash

set -e

skip() {
	echo "$@" 1>&2
	exit 0
}


[ "${TRAVIS_COMMIT_MESSAGE}" == "${TRAVIS_COMMIT_MESSAGE/Travis #/}" ] || \
	skip "Skipped... because this is travis autocommit."

[ "${TRAVIS_PULL_REQUEST}" = "false" ] || \
	skip "Skipped... because this is pull request."

[ "${TRAVIS_BRANCH}" = "master" ] || \
	skip "Skipped... because this is not a master branch (current: ${TRAVIS_BRANCH})."

[ "${TRAVIS_REPO_SLUG}" = "ru-de/faq" ] || \
	skip "Skipped... because this is not an original repository (current: ${TRAVIS_REPO_SLUG})."

[ "${GH_TOKEN+set}" = set ] || \
	skip "Skipped... GitHub access token not available"

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"

git remote add upstream https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git > /dev/null 2>&1
git fetch upstream --depth=3 -q
git checkout upstream/master -q

LC_ALL=ru_RU.UTF8 sort files/dictionary.dic -o files/dictionary.dic -f

if ! git diff --quiet; then
	git commit -q -am "Travis #$TRAVIS_BUILD_NUMBER: dictionary rearrangement"
	git push -q upstream HEAD:master
	echo "Dictionary was rearranged"
fi

git checkout upstream/gh-pages
bash update.sh > /dev/null 2>&1

if ! git diff --quiet; then
	git commit -q -am "Travis #$TRAVIS_BUILD_NUMBER: sync github pages"
	git push -q upstream HEAD:gh-pages
	echo "Github pages was updated"
fi
