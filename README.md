# nilaway-plugin

NilAway, as its current form, still reports a fair number of false positives. This makes NilAway fail to be merged with golangci-lint and be offered as a linter (see [PR#4045](https://github.com/golangci/golangci-lint/issues/4045)). 

It's a custom build plugin to add [nilway](https://github.com/uber-go/nilaway) to golangci-lint.

## Usage
the scripts will automatically detect the go version, OS and ARCH. 
Because building plugins need the dependency versions between the plugin and linter to be consistent, the script detects that automatically.


### Locally
- clone the repo.
- run `./local_build.sh` 
- copy the produced `nilaway.so` file to your project dir.
- add the custom plugin config under `linters-settings`
    ```yaml
    custom:
    nilaway:
        path: ./nilaway.so
        # The description of the linter.
        # Optional.
        description: This is a custom nilaway plugin linter.
        # Intended to point to the repo location of the linter.
        # Optional.
        original-url: github.com/moogacs/nilaway-plugin
        settings: # Settings are optional.
        one: Foo
        two:
          - name: Bar
        three:
          name: Bar
    ```

### Github actions

add this step in your gha workflow file, before the usage of golangci-lint

```yaml
 - name: golangci-lint-build-plugin
    run: |          
        git clone https://github.com/moogacs/nilaway-plugin.git
        cd nilaway-plugin
        chmod +x build.sh
        ./build.sh v{used golangci-lint version} 
        # for example ./build v1.54
```

add the plugin configuration to your `golangci.yaml` file

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
        one: Foo
        two:
          - name: Bar
        three:
          name: Bar
```

## Usful links 
- for more info about plugins [configuration](https://golangci-lint.run/contributing/new-linters/#configure-a-plugin).
- for NilAway [configuration](https://github.com/uber-go/nilaway/wiki/Configuration)
