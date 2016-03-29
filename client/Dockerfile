from mvdan/fdroid-ci:base-20160329

# SDK deps for the client (buiding & testing)

# SDK components - the sdk is too dumb to just use `yes`, it will read
# more than one line per question
run { while true; do echo y; sleep 1; done } | android -s update sdk --no-ui -a -t android-23,extra-android-m2repository,android-10
