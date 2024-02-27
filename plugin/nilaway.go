// This must be package main
package main

import (
	"go.uber.org/nilaway"
	"golang.org/x/tools/go/analysis"
)

func New(conf any) ([]*analysis.Analyzer, error) {
	return []*analysis.Analyzer{nilaway.Analyzer}, nil
}
