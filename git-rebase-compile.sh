#!/bin/sh

# Go through each commit of a branch to test if it's compilable.
# In the end, report the commits that broke the build.

ANSI_HIGHLIGHT_RED_ON="\x1B[1;31m"
ANSI_HIGHLIGHT_OFF="\x1B[0m"


rev=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
cmd="$2"
build_bork=""
cmd_bork=""

function list_bork() {
    list="$1"
    msg="$2"

    [ -n "$list" ] && {
        echo "The following commits $msg:"
        for i in $list
        do
            git log --oneline -1 $i
        done
    }
}

for i in $(git rev-list --reverse ${1}..HEAD)
do
    git checkout $i
    make -j5 || {
        echo -e "$ANSI_HIGHLIGHT_RED_ON commit $i broke build $ANSI_HIGHLIGHT_OFF"
        build_bork="$build_bork $i"
        continue
    }

    [ -n "$2" ] && {
        $2 || {
            echo -e "$ANSI_HIGHLIGHT_RED_ON commit $i broke \"$cmd\" $ANSI_HIGHLIGHT_OFF"
            cmd_bork="$cmd_bork $i"
        }
    }
done

list_bork "$build_bork" "failed to build"
list_bork "$cmd_bork" "failed to run \"$cmd\""

git checkout $rev
