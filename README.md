# Package for kpack dependencies

### Create a new deps package

1. Assemble bundle config. Example:
   
```bash
cp -r bundle templated-bundle
store_images="$(cat << END
  - gcr.io/paketo-buildpacks/java@sha256:8b0efb468411929005ddae01fdc9143f247f45f6de7a513dc7fab047fcb3e8a9
  - gcr.io/paketo-buildpacks/java-native-image@sha256:409fd29a2ecdfa98d52a7023175ece3ae435b636cd2458ea2655490504753949
  - gcr.io/paketo-buildpacks/nodejs@sha256:34813ead861ab5a6d98d45d244006e5122c47a7c0e714f524566fa916f2dd529
  - gcr.io/paketo-buildpacks/go@sha256:077aeb6e0f3e4f648b935ef584d07028e3df894cdff3cbc68cdab1d42b57781c
  - gcr.io/paketo-buildpacks/python@sha256:587f76bcf545d361703e46a99aac818216f3e664acde17c932a6975b2f1dde20
  - gcr.io/paketo-buildpacks/dotnet-core@sha256:0e94d7990b625a2224a35207f66229aecd146b901d102a501d31f1aefd85cff5
  - gcr.io/paketo-buildpacks/nginx@sha256:f30941ad9db5f62c23846667240a183ac6c95ff20bccf411ac297264fcf578c5
END)"
ytt -f templated/ \
  -v base_run_image=paketobuildpacks/run@sha256:bcab6379bf83f0657dab49f08c7da7f23a6b18145352b2e13178e35cf6bd39c1 \
  -v base_build_image=paketobuildpacks/build@sha256:99afd42fd1730b16be0bbead05b51c1f926a501291d480c8ec17febdd0ccd244 \
  --data-value-yaml store_images="$store_images" \
  > templated-bundle/config/dependencies.yaml
kbld -f templated-bundle/config --imgpkg-lock-output templated-bundle/.imgpkg/images.yml
```
   
2. Push bundle image
   
   ```bash
   imgpkg push -b <repo> -f templated-bundle --lock-output pushed_bundle.lock
   ```
   
3. Copy image reference from pushed_bundle.lock and use it to template package

   ```bash
   ytt -f package -v bundle_image=<pushed bundle ref> -v version=$VERSION > templated-package.yaml
   ```

### Install the deps package
   
0. prerequisite: install kapp-controller

   ```bash
   kapp deploy -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
   ```

1. Apply the templated package from above along with the metadata.yaml
   
   ```bash
   kapp deploy -a kpack-deps-package -f templated-package.yaml
   ```
2. Install the package
   
   ```bash
   tanzu package installed create kpack-dependencies \
     --package-name kpack-dependencies.community.tanzu.vmware.com \
     --version $VERSION \
     --values-file=<(echo "repository: <repo>")
   ```
