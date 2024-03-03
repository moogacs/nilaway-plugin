#!/bin/bash

set -euo pipefail

YELLOW=$'\e[0;33m'
NC=$'\e[0m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

[[ -z "${GITHUB_WORKSPACE:-}" ]] && echo "\$GITHUB_WORKSPACE is not set." && exit 1

[[ -z "${1:-}" ]] && echo "usage: $0 (v1.X.X|latest)" && exit 1

gomod=$(go list -m -json github.com/golangci/golangci-lint@"$1" | grep -o '"GoMod": "[^"]*' | grep -o '[^"]*$')
output=$(cat "$gomod")
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE '^go [0-9]+\.[0-9].+' <<< "$output" | cut -d ' ' -f2)

local_go_version=$(go version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ "$local_go_version" != "$go_version" ]]; then
  echo "${YELLOW}warning: local go version ($local_go_version) != go version in go.mod from golangci-lint@$1  ($go_version)${NC}"
  echo "continuing build like normal ..."
fi

[[ -f "go.mod" || -f "go.sum" ]] && rm -f go.*

go mod init github.com/nilaway-plugin
go mod tidy
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

go build -o "$GITHUB_WORKSPACE/.plugins/nilaway.so"  -buildmode=plugin -trimpath plugin/nilaway.go
echo "nilaway.so is built compatible with golangci-lint@$1."
