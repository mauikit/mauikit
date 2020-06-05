#!/bin/bash

SCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
hooks="pre-commit"

for hook in $hooks; do
    ln -s ../../.hooks/$hook $SCRIPTPATH/../.git/hooks/$hook;
done

