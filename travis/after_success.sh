#!/bin/bash
set -ev

########
# OS X #
########
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    # Report code coverage
    bash <(curl -s https://codecov.io/bash) -f packaging/root/apple-macos-all-x86_64/results/coverage.info
fi
