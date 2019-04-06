#!/bin/sh

TARGET_NAME=Amby
XCODE_SETTINGS="${TARGET_NAME}.settings"
 
xcodebuild -showBuildSettings -target $TARGET_NAME > ${XCODE_SETTINGS}
xcode_setting() {
    echo $(cat ${XCODE_SETTINGS} | awk "\$1 == \"${1}\" { print \$3 }")
}
 
export PODS_ROOT=$(xcode_setting "PODS_ROOT")
export SRCROOT=$(xcode_setting "SRCROOT")

# r.swift
# $PODS_ROOT/R.swift/rswift generate $SRCROOT/R.generated.swift

# env.plist
if [ ! -e ${SRCROOT}/Model/env.plist ]; then
  cp -pR ${SRCROOT}/Model/env-dummy.plist ${SRCROOT}/Model/env.plist
fi

if [ ! -e ${SRCROOT}/Amby/Environment/Amby/env.plist ]; then
  cp -pR ${SRCROOT}/Amby/Environment/Amby/env-dummy.plist ${SRCROOT}/Amby/Environment/Amby/env.plist
fi

# carthage
carthage bootstrap  --platform ios
