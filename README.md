# Parker

## Before You Begin
The Google API key being used is from a burner account, so don't go overboard with the API calls. Even better if you use your own API key in and ignore the files from commits. API keys are stored in 
```
project/lib/constants.dart
project/android/app/src/main/AndroidManifest.xml
project/ios/Runner/AppDelegate.swift
```

## Prerequisites
Before building the project, ensure all dependencies are installed locally first, run the following at the project folder

```
flutter pub get
```

If you get any errors with building initially, try clearing all external files from the project before running the "pub get" command

```
flutter clean
```

## Starting on the Project
The project starts from the lib/main.dart file under its main() function. Try to keep each "screen" as its own separate .dart file and import them when needed.
