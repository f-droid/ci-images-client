# F-Droid CI images

These are images used in F-Droid's continuous integration via Gitlab.
They are built via Docker.

https://hub.docker.com/r/fdroid/ci/

### base

Based on `jessie-backports`, installs the basic components (python, SDK,
etc) required across all three repos (client, server, data).

### client

Adds stuff that only the client tests need, like emulator images.

### server

Adds stuff that only the server tests need, like python linters.

These are built by gitlab-ci here:
https://gitlab.com/fdroid/ci-images/
