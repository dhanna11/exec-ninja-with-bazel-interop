#!/usr/bin/env bash

# --- begin runfiles.bash initialization ---
# The runfiles library itself defines rlocation which you would need to look
# up the library's runtime location, thus we have a chicken-and-egg problem.
#
# Copy-pasted from Bazel's Bash runfiles library (tools/bash/runfiles/runfiles.bash).
set -euo pipefail
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  if [[ -f "$0.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
  elif [[ -f "$0.runfiles/MANIFEST" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
  elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    export RUNFILES_DIR="$0.runfiles"
  fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

locc="$(rlocation $TEST_WORKSPACE)/$1"

if [ "$2" == "true" ]
then
  par_dir=$(dirname "$locc")
  grand=$(dirname "$par_dir")
  cp $locc --target-directory="$grand"
  locc="$grand/$(basename $locc)"
fi

echo "=========\n\n"
ls -laR $(dirname $locc)
echo "=========\n\n"

echo "Running $(basename $locc) in $(dirname $locc)"
result=$($locc)

if [ "$result" == "Calling them all: <From funA><From funA><From funB><From funC>" ]
then
  echo "Passed"
else
  echo -e "Unexpected output: $result"
  exit 1
fi
