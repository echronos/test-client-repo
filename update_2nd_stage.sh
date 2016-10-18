#!/bin/sh

set -e
set -u

initialize_core ()
{
    if git submodule status core | grep '^-' > /dev/null; then
        git submodule --quiet init core
    fi
    if git submodule status core | grep '^+' > /dev/null; then
        git submodule --quiet update core
    fi
}

list_branches ()
{
    local DIR="${1:-.}"
    git -C "${DIR}" branch -r | sed -n -r '/origin\/.*\// ! { s/.*origin\///; p }' | grep -v '^master$'
}

list_core_branches_and_rev_ids ()
{
    list_branches core | while read B; do echo "${B} $(git -C core rev-list --max-count=1 origin/${B})"; done
}

branch_exists ()
{
    git show-ref --quiet "${1}"
}

branch_is_uptodate_with_master ()
{
    local BRANCH MASTER_REVID
    BRANCH="${1}"
    MASTER_REVID="${2}"
    git merge-base --is-ancestor ${MASTER_REVID} "${BRANCH}"
}

branch_is_uptodate_with_core ()
{
    local BRANCH REVID
    BRANCH="${1}"
    REVID="${2}"
    git log --oneline -n 1 "${BRANCH}" core | grep "${REVID}" > /dev/null
}

branch_is_uptodate_with_origin ()
{
    local BRANCH
    BRANCH="${1}"
    test "$(git show-ref -s "heads/${BRANCH}")" = "$(git show-ref -s "origin/${BRANCH}")"
}

update_branch ()
{
    local BRANCH REVID MASTER_REVID

    BRANCH="${1}"
    REVID="${2}"
    MASTER_REVID="${3}"

    echo ""
    echo "Updating branch $BRANCH to revision $REVID"
    echo ""

    if branch_exists "origin/${BRANCH}"; then
        git checkout --quiet "${BRANCH}"
        git reset --quiet --hard origin/"${BRANCH}"
        if ! branch_is_uptodate_with_master "${BRANCH}" "${MASTER_REVID}"; then
            git merge --quiet --no-edit origin/master
        fi
    else
        if branch_exists "${BRANCH}"; then
            git branch --quiet -D "${BRANCH}"
        fi
        git checkout --quiet -b "${BRANCH}" origin/master
        git push --quiet -u origin "${BRANCH}":"${BRANCH}"
    fi

    if ! branch_is_uptodate_with_core "${BRANCH}" "${REVID}"; then
        cd core
        git checkout --quiet "${BRANCH}"
        git reset --quiet --hard origin/"${BRANCH}"
        cd ..
        git commit --quiet -m "${REVID}" core || true
    fi
}

git fetch --quiet --all --prune --recurse-submodules=yes
MASTER_REVID="$(git show-ref -s origin/master)"

initialize_core

list_core_branches_and_rev_ids | while read BRANCH REVID; do
    update_branch "${BRANCH}" "${REVID}" "${MASTER_REVID}"
done
git push --quiet --all origin

list_branches | sort > /tmp/client_branches.txt
list_branches core | sort > /tmp/core_branches.txt
BRANCHES_TO_DELETE="$(comm -23 /tmp/client_branches.txt /tmp/core_branches.txt | tr '\n' ' ')"
if [ "${BRANCHES_TO_DELETE}" != "" ]; then
    git branch --quiet --delete ${BRANCHES_TO_DELETE}
    git push --quiet --delete origin ${BRANCHES_TO_DELETE}
fi
