# Parker

## Before You Begin
The Google API key being used is from a burner account, so don't go overboard with the API calls. Even better if you use your own API key in and ignore the files from commits. API keys are stored in 
```
project/lib/constants.dart
project/android/app/src/main/AndroidManifest.xml
project/ios/Runner/AppDelegate.swift
```
Be sure to unstage any commits to the files above before pushing. We don't want our API key going public.

## Prerequisites
Install [flutter](https://flutter.dev/docs/get-started/install) and before building the project, ensure all dependencies are installed locally first, run the following at the project folder

```
flutter pub get
```

If you get any errors with building initially, try clearing all external files from the project before running the "pub get" command

```
flutter clean
```

## Android Prerequisites
If you're using an Android emulator to run the program, ensure that Google Play Services is installed else the Google Maps API won't work.

## Starting on the Project
The project starts from the lib/main.dart file under its main() function. Try to keep each "screen" as its own separate .dart file and import them when needed.

## Functional Requirements
### 1. The system must always be able to gain permission to access users’ location at any point.
#### 1.1. The system will query the user for permission to access users’ location.
- [x] 1.1.1. If succeeded, the user shall proceed to the next functionality (2).
- [x] 1.1.2. If failed, the user shall be notified that the user will not be able to proceed to the next functionality (2).


