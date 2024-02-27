module github.com/nilaway-plugin

go 1.22.0

replace golang.org/x/tools => golang.org/x/tools v0.12.0

require (
	go.uber.org/nilaway v0.0.0-20240224031343-67945fb5199f
	golang.org/x/tools v0.18.0
)

require github.com/klauspost/compress v1.17.6 // indirect
