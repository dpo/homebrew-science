#!/bin/bash
set -e

if [ "$TRAVIS_PULL_REQUEST" == "false" ]
then
    export changed_files=`git diff-tree --no-commit-id --name-only -r $TRAVIS_COMMIT | grep .rb `
else
    git fetch origin pull/${TRAVIS_PULL_REQUEST}/head:travis-pr-${TRAVIS_PULL_REQUEST}
    git checkout travis-pr-${TRAVIS_PULL_REQUEST}
    echo "commit: $TRAVIS_COMMIT"
    echo "log: $(git log -1)"
    export changed_files=`git diff-tree --no-commit-id --name-only HEAD^ HEAD | grep .rb`
fi
[[ -z "$changed_files" ]] && { echo "Nothing to test"; exit 0; }

for file in $changed_files
do
    brew install --only-dependencies $file
    # Use --skip-setup or else brew doctor fails b/c of our gcc trick.
    brew test-bot $file --skip-setup
done

