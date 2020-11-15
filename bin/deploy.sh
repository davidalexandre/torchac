#!/bin/bash

set -e

VERSION_NUMBER=$1

if [[ -z $VERSION_NUMBER ]]; then
  echo "Usage: $0 VERSION_NUMBER"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Git not clean, please commit."
  exit 1
fi

python bin/update_version.py $VERSION_NUMBER

rm -rf dist/
python setup.py bdist_wheel
twine upload dist/*

python bin/update_version.py $VERSION_NUMBER --set-used

bash pypi/test.sh tests/test.py

git commit bin/version.json -m "Updated Version: $VERSION_NUMBER"
git tag $VERSION_NUMBER
git push
git push --tags