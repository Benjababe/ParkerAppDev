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
#### 1.2. The system must continuously verify that permission to access users’ location can be accessed.
- [ ] 1.2.1 If the users’ location cannot be accessed at any point, the system must query the user for permission to access users’ location.
- [ ] 1.2.1.1 System must halt all functionalities until users’ location can be accessed again.

### 2. Users must be able to enter the start and end points of their journeys.
- [x] 2.1. The data type of entry must be a text of at least one character and less than 512characters.
- [x] 2.2. The system must confirm that users’ start and end points are valid with Google Map API.
- [x] 2.2.1. If start points or end points are not valid, the system must notify user immediately and that user will not be able to proceed to the next functionality (3).
- [x] 2.3. When confirmed, users should be able to proceed to the next functionality (3).
- [ ] 2.4. Users must be able to save some locations using the bookmark function for easier subsequent use.

### 3. The system must be able to show parking spots within 500m of users’ end points using static car park location API.
- [x] 3.1. The system must be able to show only available parking spots and users’ endpoints using real-time car park availability API.
- [x] 3.2. The system must be able to show the locations of the parking spots using a map. When a particular location is chosen by users, the users shall be able to proceed to the next functionality (4).


### 4. The system must be able to display information about users’ selected parking spots
- [x] 4.1. The selected parking spots displayed must consist of parking spots’ names.
- [x] 4.2. The selected parking spots displayed must consist of parking spots’ types. (i.e .multi-story, outdoor parking spots, etc.)
- [x] 4.3. The selected parking spots displayed must consist of number of availability of parking spots out of the total number of parking spots.
- [x] 4.4. When confirmed, users should be able to proceed to the next functionality (5).


### 5. The system must be able to display traffic directions from users’ start points to users’ selected parking spots by directing users to the Google Maps App.
- [x] 5.1 The system must be able to detect that Google Maps App has been installed in users’ devices.
- [x] 5.1.1. If Google Maps App has not been installed, the system must notify usersthat Google Maps App is needed to display traffic directions.
- [x] 5.2 The system must be able to automatically fill-up the start points in the Google Maps App.
- [x] 5.3 The system must be able to automatically fill-up the end points in the Google Maps App.

## Non-Functional Requirements
### Usability
-[ ] 1. The system must be able to display information on four of Singapore's most common languages: English, Malay, Tamil, Chinese.
-[x] 1.1. The default language of the system is English.
-[ ] 1.2. The users must be able to change the system's language on settings.

-[x] 2. 80% of first time users must be able to enter a simple search query within 2 minutes of starting to use the system.

-[x] 3.The system must be able to  suggest locations using a dropdown list with Google
   Auto-complete API, while the user is entering the start and end points. 

### Reliability
-[x] 4. After a system reboot, full system functionality must be restored within 5 seconds.

### Performance
-[x] 5. The system must be able to show parking spots within 500m of users’ end points within 10
    seconds.

### Supportability 
-[x] 6. The system must be able to access the API using the HTTP GET request.
-[x] 7. System must be able to be run in iOS and Android.