## Analytics server

### Local running

To run the app use `gradle bootRun` command. Before starting the app make sure
that it's dependencies are up and running. It requires `mongodb` and `redis` and optionally
a `nginx` (it sends `x-forwarded-for` header that is used by the API).

### Building the app using jib

In order to build the image that can run both on x86 and arm, use the `jib` plugin.
Steps to release the app:

1. Tag the commit using format `analytics-server/<version>`. Any string is a valida version.
2. Run `tools/relase.sh` script. Artifact should be available
   at [dockerhub](https://hub.docker.com/r/m1loseph/phd-website-analytics-server/tags).
