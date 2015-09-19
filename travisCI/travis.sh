#!/bin/bash
set -evx

if [ "$TRAVIS_PULL_REQUEST" ==  "false" ]
then
  export changed_files=$(git diff-tree --no-commit-id --name-only -r $TRAVIS_COMMIT | grep .rb)
else
  git fetch origin pull/${TRAVIS_PULL_REQUEST}/head:travis-pr-${TRAVIS_PULL_REQUEST}
  git checkout travis-pr-${TRAVIS_PULL_REQUEST}
  echo "commit: $TRAVIS_COMMIT"
  echo "log: $(git log -1)"
  export changed_files=$(git diff-tree --no-commit-id --name-only HEAD^ HEAD | grep .rb)
fi

echo "Formulae to build: $changed_files"
for file in $changed_files
do
  brew test-bot $file --skip-setup --keep-logs
  for item in $(brew uses $file) 
  do
    brew test-bot $item --skip-setup --keep-logs
  done
done
