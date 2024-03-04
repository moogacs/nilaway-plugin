# nilaway-plugin

NilAway, as its current form, still reports a fair number of false positives. This makes NilAway fail to be merged with golangci-lint and be offered as a linter (see [PR#4045](https://github.com/golangci/golangci-lint/issues/4045)). 

It's a custom build plugin to add [nilaway](https://github.com/uber-go/nilaway) to golangci-lint.

## Usage

### Build

The build script lets you do 2 things:

1. Build the nilaway plugin based on the golangci-lint version in your PATH.
This could be a binary you compiled yourself (recommended) or a binary you downloaded from brew or some other place.
2. Build the plugin based on a specific version of golangci-lint OR the latest version.

```bash
./build local                # use what's in $PATH    - get info about the binary using 'go version'
./build (v1.X.X|latest)      # use a specific version - get info from the go.mod using 'go list'
```

The build scripts will automatically detect the go version, GOARCH and GOOS.
If you don't the build script to overwrite those variables, you can `export` them beforehand, or set them in your CI pipeline.

Because building plugins need the dependency versions between the plugin and linter to be consistent, the script detects that automatically.

### Locally

- clone the repo.
- run `./build.sh local`
- copy the produced `nilaway.so` file to your project dir.
- add the custom plugin config under `linters-settings`
    ```yaml
    custom:
      nilaway:
        path: .plugins/nilaway.so
        # The description of the linter.
        # Optional.
        description: This is a custom nilaway plugin linter.
        # Intended to point to the repo location of the linter.
        # Optional.
        original-url: github.com/moogacs/nilaway-plugin
        settings: # Settings are optional.
          pretty-print: true
          exclude-pkgs: "pkgA,pkgB"

### GitHub Actions

add this step in your gha workflow file, before the usage of golangci-lint

```yaml
 - name: golangci-lint-build-plugin
    run: |          
        git clone https://github.com/moogacs/nilaway-plugin.git
        cd nilaway-plugin
        chmod +x build.sh
        ./build.sh v1.X.X # or use 'latest' or 'local'
        # the compiled .so file will be in $GITHUB_WORKSPACE/.plugins OR
        # the current directory.
```

add the plugin configuration to your `golangci.yaml` file, just like in the [previous section](#locally).

## Useful links  
- for more info about plugins [configuration](https://golangci-lint.run/contributing/new-linters/#configure-a-plugin).
- for NilAway [configuration](https://github.com/uber-go/nilaway/wiki/Configuration)
