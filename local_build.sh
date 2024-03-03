#!/bin/bash

set -euo pipefail

YELLOW=$'\e[0;33m'
NC=$'\e[0m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

output=$(go version -m "$(which golangci-lint)")
GOARCH=$(grep -oE 'GOARCH=\S+' <<< "$output" | cut -d '=' -f 2)
GOOS=$(grep -oE 'GOOS=\S+' <<< "$output" | cut -d '=' -f 2)
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' <<< "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

local_go_version=$(go version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ "$local_go_version" != "$go_version" ]]; then
  echo "${YELLOW}warning: local go version ($local_go_version) != go version used to build $(which golangci-lint) ($go_version)${NC}"
  echo "continuing build like normal ..."
fi

[[ -f "go.mod" || -f "go.sum" ]] && rm -f go.*

set -x
go mod init github.com/nilaway-plugin
go mod tidy
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

GOARCH=$GOARCH GOOS=$GOOS go build -buildmode=plugin -trimpath -o nilaway.so ./plugin/nilaway.go
set +x

echo "nilaway.so is built compatible with local golangci-lint, please move it under your project directory" \
  "and make sure to copy the custom settings to your .golangci.yml file."
