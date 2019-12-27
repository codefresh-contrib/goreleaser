# !/bin/bash

set -e

bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }
ok() { green OK ; }

function getContextFromTrigger() {
    checkTrigger || return 1
    GIT_CONTEXT=$(codefresh get pipeline "$CF_PIPELINE_NAME" -o json | jq --arg triggerId "${CF_PIPELINE_TRIGGER_ID}" -r '.spec.triggers[] | select(.id == $triggerId) | .context') || return 1 
    export GIT_CONTEXT
}

function getTokenFromContext() {
    bold "Getting a git token from the context \"${GIT_CONTEXT}\"..."
    GITHUB_TOKEN=$(codefresh get contexts --type git.github ${GIT_CONTEXT} --decrypt -o json | jq -r '.spec.data.auth.password') || return 1
    export GITHUB_TOKEN
    ok
}

function checkTrigger() {
    if [ -z "$CF_PIPELINE_TRIGGER_ID" ]; then
        red "Failed to get the trigger data - the pipeline hasn't been started by a trigger"
        return 1
    fi
}

if [ -z "$GITHUB_TOKEN" ]; then
    bold "GITHUB_TOKEN is not set, trying to get it from the git context of the current trigger..."
    getContextFromTrigger
    getTokenFromContext
fi

git reset --hard
git clean -df

$@