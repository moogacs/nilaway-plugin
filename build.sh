#!/bin/bash

echo $1
gomod=$(go list -m -json github.com/golangci/golangci-lint@$1 | grep -o '"GoMod": "[^"]*' | grep -o '[^"]*$')
output=$(cat $gomod)
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

go mod init github.com/nilaway-plugin
go mod edit -replace golang.org/x/tools=golang.org/x/tools@$tools_version
go mod tidy

go build -o "$GITHUB_WORKSPACE/.plugins/nilaway.so"  -buildmode=plugin plugin/nilaway.go

echo -e "nilaway.so is built compatiable with local golangci-lint."