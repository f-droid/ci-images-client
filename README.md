# F-Droid Client CI image

Getting an Android emulator running automatically in a container-based
CI system is a difficult task.  This project makes it as easy as
possible, supporting as many emulator combinations that have proven to
run in GitLab-CI.

This Docker image is used in
[fdroidclient](https://gitlab.com/fdroid/fdroidclient)'s continuous
integration via Gitlab.  It is built on top of our
[ci-images-base](https://gitlab.com/fdroid/ci-images-base) Docker
image.  This specific image includes stuff that only the client tests need,
like emulator images.

The magic is mostly in the `start-emulator` script.  It will use KVM
if it is available, but will run in a unprivileged environment as
well, albeit slower.


## GitLab CI Example


```yaml
.connected-template: &connected-template
  image: registry.gitlab.com/fdroid/ci-images-client
  script:
    - ./gradlew assembleFullDebug # run this first to reduce concurrent RAM usage
    - start-emulator
    - wait-for-emulator
    - adb devices
    - adb shell input keyevent 82 &
    - ./gradlew connectedFullDebugAndroidTest || (adb -e logcat -d > logcat.txt; exit 1)
  artifacts:
    paths:
      - logcat.txt

connected 22 default armeabi-v7a:
  <<: *connected-template

connected 23 default aarch64:
  <<: *connected-template

connected 26 google_apis x86:
  <<: *connected-template

connected 27 google_apis_playstore x86:
  <<: *connected-template

connected 29 default x86_64:
  <<: *connected-template

```
