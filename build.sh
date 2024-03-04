#!/bin/bash

set -euo pipefail

CYAN=$'\e[0;36m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
NC=$'\e[0m'

# script-wide vars
build_out="nilaway.so"
slug=""

[[ -n "${GITHUB_WORKSPACE:-}" ]] && build_out="$GITHUB_WORKSPACE/.plugins/nilaway.so"

# set directory, parse CLI args
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

usage() {
  echo "usage: $0 VERSION"
  echo
  echo "examples:"
  echo "  on your local machine/to build for the golangci-lint in your \$PATH:"
  echo "    $0 local"
  echo
  echo "  in ci/to build for a specific golangci-lint version or latest:"
  echo "    $0 (v1.X.X|latest)"
  echo
  echo "  if \$GITHUB_WORKSPACE is set, the .so files will be output in \$GITHUB_WORKSPACE/.plugins/"
  echo "    otherwise, they will be output in $SCRIPT_DIR/"
  exit 1
}

case "${1:-}" in
  local)
    slug="$(which golangci-lint)"
    ;;
  latest|v[0-9]*)
    slug="golangci-lint@$1"
    ;;
  *)
    usage
    ;;
esac
echo "${CYAN}building nilaway plugin to be compatible with: ${slug}${NC}"

# gather info about golangci-lint version the plugin is being built for
# set: tools_version, go_version
# also set: GOARCH, GOOS -- only if they are not set already.
if [[ "$1" == "local" ]]; then
  output=$(go version -m "$(which golangci-lint)")
  tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  go_version=$(grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' <<< "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

  # go version should provide info about GOARCH/GOOS, set it
  [[ -z "${GOARCH:-}" ]] && GOARCH=$(grep -oE 'GOARCH=\S+' <<< "$output" | cut -d '=' -f 2) && echo "${YELLOW}\$GOARCH was empty, now set to ${GOARCH}${NC}"
  [[ -z "${GOOS:-}" ]] && GOOS=$(grep -oE 'GOOS=\S+' <<< "$output" | cut -d '=' -f 2) && echo "${YELLOW}\$GOOS was empty, now set to ${GOOS}${NC}"
else
  gomod=$(go list -m -json github.com/golangci/golangci-lint@"$1" | grep -o '"GoMod": "[^"]*' | grep -o '[^"]*$')
  output=$(cat "$gomod")
  tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  go_version=$(grep -oE '^go [0-9]+\.[0-9].+' <<< "$output" | cut -d ' ' -f2)

  # go.mod does not give any GOARCH/GOOS info, so just use what is in go env
  [[ -z "${GOARCH:-}" ]] && GOARCH=$(go env | grep GOARCH | sed s/\'//g | cut -d '=' -f 2) && echo "${YELLOW}\$GOARCH was empty, now set to ${GOARCH}${NC}"
  [[ -z "${GOOS:-}" ]] && GOOS=$(go env | grep GOOS | sed s/\'//g | cut -d '=' -f 2) && echo "${YELLOW}\$GOOS was empty, now set to ${GOOS}${NC}"
fi

# different go versions could potentially cause a problem, inform user
local_go_version=$(go version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ "$local_go_version" != "$go_version 1" ]]; then
  echo "${YELLOW}warning: local go version ($local_go_version) != go version for $slug ($go_version), this could potentially cause problems${NC}"
  echo "continuing build like normal ..."
fi

# perform build
[[ -f "go.mod" || -f "go.sum" ]] && rm -f go.*
set -x
go mod init github.com/nilaway-plugin
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

GOARCH=$GOARCH GOOS=$GOOS go build -o "$build_out"  -buildmode=plugin -trimpath plugin/nilaway.go

set +x
echo "${GREEN}nilaway.so is built compatible with local golangci-lint, please move it under your project directory" \
  "and make sure to copy the custom settings to your .golangci.yml file.${NC}"
