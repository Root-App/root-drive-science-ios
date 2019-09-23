#  Drive Science iOS Test App

## Purpose

This repo contains a sample iOS app that uses the iOS SDK to retrieve a trip token from
the Root servers. 

## Using the iOS SDK

The sample code to connect to the SDK can be found in the `AppDelegate.swift` file
and the `ViewController.swift` file.

In your `Podfile`, add dependencies for the following libraries:

```
source 'git@github.com:root-app/root-pod-specs.git'

pod "RootTripTracker", "3.6.0"
pod 'RootReliableAPI', "3.1.0"
```

In order to connect to the TripTracker, you need a Root Client ID. The file that connects to
the TripTracker needs to import the `RootTripTracker` code:

```
import RootTripTracker
```

Then, you can obtain a TripTracker instance by calling 
`TripTracker(environment: <Environment>)`. The value of `Environment` is one
of `.production`, `.staging`, `.testing`, or `.local`.


With that instance, you can obtain a user token and start tracking with `start`. The initial 
signtature of  `start` if you have a Client ID but not a token is:

```
public func start(
    clientID: String,
    didSucceedCallback: @escaping TypeTrackerStarted = TripTracker.defaultTokenCallback,
    didFailCallback: @escaping TypeTrackerStarted = TripTracker.defaultTokenCallback) -> Void"
```

If the token creation succeeds, the TripTracker receives the token, starts tracking, and 
calls the `didSucceedCallback` closure with the new token as an argument. In this 
callback, you would typically do anything you need to do with the token to assoicate it
wtih the current user. 

The default callback is just a no-op.

In subsequent uses, if you have the token, you would call start with a different 
set of arguments:

```
public func start(
clientID: String,
accessToken: String,
didSucceedCallback: @escaping TypeTrackerStarted = TripTracker.defaultTokenCallback) -> Void
```

You pass the `clientID` and the `accessToken` and the success handler. There's no
failure handler because if the tracker already has the token, it won't call the server API,
removing the failure case. 

If the token creation fails, the `didFailCallback` will get called with a string 
represention of the error as an argument. 


## Development Requirements

To test against a local envrionment, set the following keys in the `info.plist` file of your
application: 

- `ROOTLocalServerIP`: The IP address of your local server, without `http` or `https`.
- `ROOTLocalServerPort` The port used to connect to your local server, if needed. If not 
    needed, just leave it blank.
    
    Then set the environment to local when you instantiate the TripTracker, 
    `TripTracker(environment: .local)`.
    
    The production environment looks for `telematics.api.joinroot.com`, the staging
    environment looks for `telematics.api.staging.joinroot.com`.
    
    ```




