#!/bin/bash

echo "$1"
gomod=$(go list -m -json github.com/golangci/golangci-lint@"$1" | grep -o '"GoMod": "[^"]*' | grep -o '[^"]*$')
output=$(cat "$gomod")
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE '^go [0-9]+\.[0-9].+' <<< "$output" | cut -d ' ' -f2)

local_go_version=$(go version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ "$local_go_version" != "$go_version" ]]; then
  echo -e "FYI - the go version being used right now ($local_go_version) is not the same" \
      "as the one from the go.mod file for golangci-lint ($go_version)"
    echo -e "continuing the build like normal ..."
fi

go mod init github.com/nilaway-plugin
go mod tidy
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

go build -o "$GITHUB_WORKSPACE/.plugins/nilaway.so"  -buildmode=plugin -trimpath plugin/nilaway.go && \
  echo -e "nilaway.so is built compatible with golangci-lint $1."
