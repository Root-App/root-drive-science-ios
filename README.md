#  Drive Science iOS Test App

## Purpose

This repo contains a sample iOS app that uses the iOS SDK to retrieve a trip token from the Root servers.

## iOS SDK Requirements

The Root Trip Tracker SDK does not support Swift 5.

Root's Trip Tracker SDK is known to be compatible with Cocoapods 1.6.2. It my not support Cocoapods 1.7.x or 1.8.x.

In your `Podfile`, add dependencies for the following libraries:

```
source 'git@github.com:root-app/root-pod-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod "RootTripTracker", "3.6.0rc1"
```

From a terminal in the same directory as your Podfile

```
pod install
```

## Connecting to Trip Tracker

The file that connects to the TripTracker needs to import the `RootTripTracker` code:

```
import RootTripTracker
```

In order to connect to the TripTracker, you need a Root Client ID. 

There are four calls that you need to make to provision the TripTracker with a driver ID and start the tracker.

First, you obtain a TripTracker instance by calling
`TripTracker(environment: <Environment>)`. The value of `Environment` is one of `.production`, `.staging`, `.testing`, or `.local`. 

Second, you need to get a `TripTrackerOnboarder` instance: 

```
let onboard = TripTrackerOnboarder(
	tracker = TripTracker(environment: .local) 
  clientId: "your-client-id-here",
  tripTracker: tracker,
  delegate: <a delegate>
)
```

The `delegate` object needs to implement the `TripTrackerOnboarderDelegate` protocol, which has two methods:

```
public protocol TripTrackerOnboarderDelegate {
    func didReceiveTelematicsToken(_ token: String)
    func didNotReceiveTelematicsToken(_ errorMessage: String)
}
```

The delegate should also at least be able to reference the TripTracker instance so that it can start the tracker.

Third, you need to call a method on the `TripTrackerOnboarder` to associate a driver token with the tracker. If you do not have a client token, call `onboarder.onboardWithoutToken()`. If you do have a client token (presumably because the user has already been granted on), then you call `onboarder.onboardWithToken(token)`.

The `onboardWithoutToken` method will make an API call to receive a token. If that method fails, the `didNotReceiveTelematicsToken` of the delegate will be invoked.

Fourth, if the call is successful or if you pass the driver token, the delegate `didReceiveTelematicsToken` method is invoked. In that method you should call the `start` method on the TripTracker. You can also use this delegate method to store the client id and associate with the user as your application needs. 

## Development Requirements

To test against a local environment, set the following keys in the `info.plist` file of your
application:

- `ROOTLocalServerIP`: The IP address of your local server, without `http` or `https`.
- `ROOTLocalServerPortMode`: Has one of three values. Use `Default` if the local port is `:3000`, use `None` if your local server doesn't use a port (for example, if you are using ngrok), use `Custom` if you need to specify a different port. 
- `ROOTLocalServerPort` If your port mode is `Custom`, specify the port number in this key, otherwise you can leave it blank.

Then set the environment to local when you instantiate the TripTracker,  `TripTracker(environment: .local)`.

The production environment looks for the server at `telematics.api.joinroot.com`, the staging
environment looks for the server at `telematics.api.staging.joinroot.com`.





