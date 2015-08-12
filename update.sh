#!/bin/sh

date

set -e
set -u

eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa_teamcity

print_core_branches_and_rev_ids ()
{
    cd core
    git fetch --all --prune > /dev/null 2>&1
    git branch -r | sed -n -r '/origin\/.*\// ! { s/.*origin\///; p }' | while read B; do echo "$B $(git rev-list --max-count=1 origin/$B)"; done
    cd ..
}

update_branch ()
{
    local BRANCH REVID

    BRANCH="${1}"
    REVID="${2}"

    echo "Updating branch $BRANCH to revision $REVID"

    if git branch -a | grep "${BRANCH}"; then
        if git log -n 1 --oneline "origin/${BRANCH}" | grep "${REVID}" > /dev/null; then
            return 0
        fi
        git checkout "${BRANCH}"
        git reset --hard origin/"${BRANCH}"
    else
        git checkout -b "${BRANCH}" origin/master
    fi

    cd core
    git checkout "${BRANCH}"
    git reset --hard origin/"${BRANCH}"
    cd ..

    git commit core -m "${REVID}" || true
    git push -u origin "${BRANCH}"
}

git fetch --all --prune
print_core_branches_and_rev_ids | while read BRANCH REVID; do update_branch "${BRANCH}" "${REVID}"; done

ssh-agent -k

