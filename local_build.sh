#!/bin/bash

output=$(go version -m echo $(which golangci-lint))
GOARCH=$(grep -oE 'GOARCH=\S+' <<< "$output" | cut -d '=' -f 2)
GOOS=$(grep -oE 'GOOS=\S+' <<< "$output" | cut -d '=' -f 2)
tools_version=$(grep 'golang.org/x/tools' <<< "$output" | grep -oE '\bv[0-9]+\.[0-9]+\.[0-9]+\b' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
go_version=$(grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' <<< "$output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

echo building nilaway.so with GOARCH=$GOARCH GOOS=$GOOS tools_version=$tools_version go_version=$go_version ...
GOARCH=$GOARCH GOOS=$GOOS go build -buildmode=plugin -o nilaway.so ./plugin/nilaway.go
echo -e "nilaway.so is built compatiable with local golangci-lint, please move it under your project directory and make sure to copy the custom seetings to your .golangci.yml file."
