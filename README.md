# bluetooth-door-lock
## Firmware
Door Lock implemented with a Feedback Servo, an Adafruit nRF52840 Express, an Adafruit Servo Featherwing, and some 3D printed parts..

## UI
User-facing software implemented as an iPhone app with SwiftUI, CoreBluetooth and SQLite. With full backgrounding support for the ultimate seamless experience.

The app uses [Tuist](https://tuist.io) instead of Xcode project management as an experiment for work, and also because I don't want to commit a bunch of semi-sensitive information from Xcodeproj files.

## If I could turn back time... (2026)
I would've done the following differently:

- CoreBluetooth implementation is a mess -- Use [AsyncCoreBluetooth](https://GitHub.com/meech-ward/AsyncCoreBluetooth)?
- Use GATT attributes for lock / closed instead of a haphazardly hacked together serial port
- (Physical) Use more secure mounting and fastening options on a custom PCB
- Prevent snooping from other iOS apps w/ [`AccessorySetupKit`](https://developer.apple.com/documentation/accessorysetupkit) so it's E2E secure and security isn't terminated by iOS's Bluetooth stack and allowing any apps on a bonded to use it. This gets theoretical quickly. https://xkcd.com/538) -- I'm securing a wooden door with a physical key hole that can literally be picked in a minute.
