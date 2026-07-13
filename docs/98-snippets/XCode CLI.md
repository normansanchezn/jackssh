---
tags:
  - ide/xcode
  - compile
  - xcode/project
  - xcode/cli
  - xcode/snippet
Created at: 2026-07-13
---
## List devices

```
xcrun devicectl list devices
```

## Compile project on iPhone

```
xcodebuild \
  -project JackSsh/JackSsh.xcodeproj \
  -scheme JackSsh \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ./DerivedData \
  -allowProvisioningUpdates \
  build
```

## Build project
```
xcodebuild -project JackSsh/JackSsh.xcodeproj -scheme JackSsh -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```
