#!/bin/bash

output=$(go version -m "$(which golangci-lint)")
GOARCH=$(grep -oE 'GOARCH=\S+' <<< "$output" | cut -d '=' -f 2)
GOOS=$(grep -oE 'GOOS=\S+' <<< "$output" | cut -d '=' -f 2)
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' <<< "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

echo "$tools_version"
go mod init github.com/nilaway-plugin
go mod tidy
go mod edit -replace golang.org/x/tools=golang.org/x/tools@v"$tools_version"
go mod tidy

echo building nilaway.so with GOARCH="$GOARCH" GOOS="$GOOS" tools_version="$tools_version" go_version="$go_version" ...
GOARCH=$GOARCH GOOS=$GOOS go build -buildmode=plugin -trimpath -o nilaway.so ./plugin/nilaway.go && \
  echo -e "nilaway.so is built compatible with local golangci-lint, please move it under your project directory" \
    "and make sure to copy the custom settings to your .golangci.yml file."
