#  Drive Science iOS Test App

## Purpose

This repo contains a sample iOS app that uses the iOS SDK to retrieve a trip token from the Root servers.

## iOS SDK Documentation

See [iOS SDK documentation](https://github.com/Root-App/drive-science-docs/blob/master/ios.md) in the Drive Science docs.


## Development Requirements

To test against a local environment, set the following keys in the `info.plist` file of your
application:

- `ROOTLocalServerIP`: The IP address of your local server, without `http` or `https`.
- `ROOTLocalServerPortMode`: Has one of three values. Use `Default` if the local port is `:3000`, use `None` if your local server doesn't use a port (for example, if you are using ngrok), use `Custom` if you need to specify a different port.
- `ROOTLocalServerPort` If your port mode is `Custom`, specify the port number in this key, otherwise you can leave it blank.

Then set the environment to local when you instantiate the TripTracker,  `TripTracker(environment: .local)`.

The production environment looks for the server at `telematics.api.joinroot.com`, the staging
environment looks for the server at `telematics.api.staging.joinroot.com`.





