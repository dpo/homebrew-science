#!/bin/bash
set -ev

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

bot_options='--skip-setup --skip-homebrew --keep-logs'
for file in $changed_files
do

  formula=$(basename $file .rb)

  # brew test-bot $file $bot_options  # The BrewTestBot already does this.
  brew install $formula --only-dependencies  # Use bottles for dependencies.
  brew install $formula
  brew test $formula

  # Check breakage of any dependent.
  for item in $(brew uses $formula) 
  do
    dependent=$(basename $item .rb)
    brew install $dependent --only-dependencies  # Use bottles for dependencies.
    brew install $dependent --build-from-source
    brew test $dependent
  done
done
