#!/bin/bash

set -e

skip() {
	echo "$@" 1>&2
	echo "Exiting..." 1>&2
	exit 0
}

[ "${TRAVIS_COMMIT_MESSAGE}" == "${TRAVIS_COMMIT_MESSAGE/Travis build/}" ] || \
    skip "Skip for travis updates."

[ "${TRAVIS_PULL_REQUEST}" = "false" ] || \
    skip "Not running master-only script for pull-requests."

[ "${TRAVIS_BRANCH}" = "master" ] || \
    skip "Running master-only for updates on 'master' branch (current: ${TRAVIS_BRANCH})."

[ "${TRAVIS_REPO_SLUG}" = "ru-de/faq" ] || \
    skip "Running master-only for updater on main repo (current: ${TRAVIS_REPO_SLUG})."

[ "${GH_TOKEN+set}" = set ] || \
    skip "GitHub access token not available, skipping dict check."

dict_check() {
    LC_ALL=ru_RU.UTF8 sort files/dictionary.dic -C || \
    (LC_ALL=ru_RU.UTF8 sort files/dictionary.dic -o files/dictionary.dic -f && bash files/push.sh)
}

dict_check
