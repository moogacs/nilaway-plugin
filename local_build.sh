#!/bin/bash

set -euo pipefail

YELLOW=$'\e[0;33m'
NC=$'\e[0m'

output=$(go version -m "$(which golangci-lint)")
GOARCH=$(grep -oE 'GOARCH=\S+' <<< "$output" | cut -d '=' -f 2)
GOOS=$(grep -oE 'GOOS=\S+' <<< "$output" | cut -d '=' -f 2)
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' <<< "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

local_go_version=$(go version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
[[ "$local_go_version" != "$go_version" ]] && \
  echo -e "${YELLOW}warning: local go version ($local_go_version) != go version used to build $(which golangci-lint) ($go_version)${NC}" &&
  echo -e "${YELLOW}continuing build like normal ...${NC}"

echo "$tools_version"
go mod init github.com/nilaway-plugin
go mod tidy
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

echo building nilaway.so with GOARCH="$GOARCH" GOOS="$GOOS" tools_version="$tools_version" local_go_version="$local_go_version" ...
GOARCH=$GOARCH GOOS=$GOOS go build -buildmode=plugin -trimpath -o nilaway.so ./plugin/nilaway.go && \
  echo -e "nilaway.so is built compatible with local golangci-lint, please move it under your project directory" \
    "and make sure to copy the custom settings to your .golangci.yml file."
