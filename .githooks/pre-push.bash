#!/bin/sh

regex='^(2026_[0-9]+|IMP|IFC|BUG|TEST): .+'

while read local_ref local_sha remote_ref remote_sha
do

    # First push of a new branch
    if [ "$remote_sha" = "0000000000000000000000000000000000000000" ]
    then
        range=$local_sha
    else
        range="$remote_sha..$local_sha"
    fi

    for commit in $(git rev-list $range)
    do
        msg=$(git log --format=%s -n 1 $commit)

        if ! echo "$msg" | grep -qE "$regex"
        then
            echo ""
            echo "❌ Push rejected"
            echo "Invalid commit message:"
            echo "$msg"
            echo ""
            echo "Allowed formats:"
            echo "  2026_6: Security component update"
            echo "  IMP: Updated checkstyle rules"
            echo "  IFC: Added interface changes"
            echo "  BUG: Fixed login issue"
            echo "  TEST: Added automated tests"
            echo ""

            exit 1
        fi
    done
done

exit 0