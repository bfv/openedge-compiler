# openedge-compiler

![Build Status CI](https://github.com/bfv/openedge-compiler/actions/workflows/ci.yaml/badge.svg)

This repo contains the nuts and bolts to create a OpenEdge compiler (OEC) Docker image. It has a template `Dockerfile` as well as Github workflows for CI and publishing releases of the OEC. Futhermore the JDK used for installing OpenEdge in the first place is configurable via `jdk-versions.json`

## Semantic and flattened version numbers
Throughout this repo two schmes are used:
- semantic - `11.7.17` for example, but `12.7.0` instead of `12.7`
- flattened - the flattend version number of `11.7.17` is `117`. This because license are for minor versions rather than the full semantic one. Github secrets don't allow periods (`.`) is their names, so they are left out


# Usage
OEC contains nothing more than an 4GL Development System installed. It is agnostic of however the software is build. The basic scheme of how this is used is:

`docker run <mappings> openedge-compiler:<semantic-version> <start-script>`

Now, this repo contains a tiny bit of OE code which is used to test if the build of OEC was succesful.
Using OEC looks like:
```
docker run \
  -v ${PWD}/src/src:/app/src \
  -v ${PWD}/artifacts:/artifacts \
  -v ${PWD}/src/progress.cfg:/usr/dlc/progress.cfg \
  ${{env.IMAGE_NAME}} \
  /app/src/scripts/build.sh
```
As background here, this repo is checked out at the `${PWD}/src` directory. Now:
| mapping | description  |
|---|---|
| `-v ${PWD}/src/src:/app/src` | mounts the entire repo at `/app/src` |
| `-v ${PWD}/artifacts:/artifacts` | location for the results (.pl) |
| `-v ${PWD}/src/progress.cfg:/usr/dlc/progress.cfg` | specifies which license to used (BYOL) |
| `${{env.IMAGE_NAME}}` | the OEC image used, f.e. openedge-compiler:12.7.0 |
| `/app/src/scripts/build.sh`   | the script which kicks-off the build, not that this is *in* your git repo |

What's in the `build.sh` script is entirely up to you. In this case it expects the software to be built is `/app/src` and want to put the output in `artifacts`


# Building and publishing OEC (via Github)

## CI
Building the actual OEC images (and the CI) is done in this case via Github Actions. The recipes for this are in the `.github/workflows` directory. The following secret are used for building the actual OEC image, we assume OE 12.7.0:
|   |   |
|---|---|
| RESPONSE_INI_127 | secret with the entire `response.ini` file needed for an unattended install |
| PROGRESS_CFG_127 | A valid cfg file which is necessary for running the OEC test |

## publish
The OEC images can be published to various registries. Per registry (f.e. Docker Hub) you need to setup a couple of things. First you need to set up an environment which can hold the secrets for the target registry. Each environment should contain the follow vars secrets:
| type | name | description  |
|---|---|---|
| var | REGISTRY_DOMAIN | the target registry domain, f.e. `docker.io` or `ghcr.io` |
| var | IMAGE_PREFIX | Think of this as the namespace within the registry, must end with `/` |
| secret | REGISTRY_USERNAME | the username for the target registry |
| secret | REGISTRY_PASSWORD | the password for the target registry |

At the moment all images are build as `openedge-compiler`. This is not configurable.

## JDK versions
The OpenEdge installer as well PCT (at container runtime) need a JDK. The necessary version may differ per OE minor version and therefor are configurable:
```
{
    "jdk117": "11.0.19_7-jdk",
    "jdk122": "11.0.19_7-jdk",
    "jdk126": "17.0.7_7-jdk",
    "jdk127": "17.0.7_7-jdk"
}
```
So, when OE is released a property `jdk128` is added with the appropriate JDK tag. These tags must refer to `eclipse-temurin` JDK image tags. See: [https://hub.docker.com/_/eclipse-temurin](https://hub.docker.com/_/eclipse-temurin). The JDK version value is used to replace the `JDKVERSION` placeholder in the Dockerfile:
```
COPY --from=eclipse-temurin:JDKVERSION $JAVA_HOME $JAVA_HOME
```

# Example (and test)
In the `src/` directory of this repo is a tiny OE/PCT build example. This is also used to test if the OEC image is ok. If not, CI and publish workflows will fail. CI can be done again several OE versions. At the time of writing the CI tests this:
```
strategy:
  matrix:
    version: [ 11.7.17, 12.6.0, 12.7.0 ]
``` 

So 3 versions.

The example/test creates a sports2020 database, compiles `getcustomers.p` (which needs the db) and puts it in the sports2020 which is placed in `/artifacts` along with a file list (`prolib -list`).

# tips
The compiler run as the `openedge` user.
When compiling on for example github, compile to a dir the container own (NOT what you mount to `/app/src` as you may not have writing permissions).
For the same reason, set `tempDir` to a dir the container owns (f.e. `/usr/wrk`)

# tags
latest = 12.8.4
