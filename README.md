# F-Droid Client CI image

This Docker image is used in
[fdroidclient](https://gitlab.com/fdroid/fdroidclient)'s continuous
integration via Gitlab.  It is built on top of our
[ci-images-base](https://gitlab.com/fdroid/ci-images-base) Docker
image.  It includes stuff that only the client tests need, like
emulator images.
