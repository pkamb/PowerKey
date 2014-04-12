#PowerKey

![PowerKey icon](http://i.imgur.com/qrLJmcV.png "PowerKey icon")

## Remap your Power key

PowerKey remaps your Macbook Pro or Macbook Air's Power key.

Remapping to Forward Delete ⌦ is the most popular replacement.

## Download

Release versions of `PowerKey.app` can be found on GitHub:

https://github.com/pkamb/PowerKey/releases

## Does not prevent Shut Down!

Your computer will still shut down if you **hold** the Power key for 5+ seconds.

Be careful! You should *tap* the Power key. Don't hold it down.

## Key Replacements

Choose from one of the following Power key replacements.

 - Delete
 - No Action
 - Page Up
 - Page Down
 - Home
 - End
 - Escape
 - Tab
 - F13

## Additional steps for OS X 10.9 Mavericks

OS X 10.9 [introduced new behavior](http://support.apple.com/kb/HT5869?viewlocale=en_US) for the Power key: 

 - Tap the power button once to put your Mac to sleep.
 - Tap the power button again to wake your Mac.

In the 10.9.2 update, Apple made this behavior configurable:

    defaults write com.apple.loginwindow PowerButtonSleepsSystem -bool NO

To disable this immediate Sleep behavior and make the Power key usable with PowerKey:

 1. Update OS X to version 10.9.2 or greater.
 2. Open Terminal.
 3. Run the command: `defaults write com.apple.loginwindow PowerButtonSleepsSystem -bool NO`
 4. Log out of your OS X account, then log back in.
 5. Run PowerKey.app; pressing the key will now *not* immediately put your Mac to sleep.
 
See [Issue #14](https://github.com/pkamb/PowerKey/issues/14) for more information.

## Screenshots

![PowerKey screenshot](http://i.imgur.com/6Z2CMat.png "PowerKey screenshot")

![PowerKey remapping options](http://i.imgur.com/NzmRKN3.png "PowerKey remapping options")

## Frequently Asked Questions

#### But my Macbook has an Eject key!

The Eject key has been replaced by Power on the newer Macbook Pro and Macbook Air models that do not feature an optical drive.

Your laptop's metal Power button (in the chassis) will actually work with this app, but it's up to you to decide if that's desirable.

PowerKey does not currently support remapping the Eject key.

#### I'm using OS X 10.9 Mavericks, and my Mac immediately goes to Sleep.

Apple changed the way the Power key works in OS X 10.9. The key now puts the computer to sleep.

You will need to run an additional command to return the Power key to pre-Mavericks behavior.

Please see the section ["Additional steps for OS X 10.9 Mavericks"](https://github.com/pkamb/PowerKey#additional-steps-for-os-x-109-mavericks) for more information.

#### Pressing the Power key doesn't always work.

Apple has made "dangerous" keys such as Caps-Lock and Power somewhat harder to accidentally press:

 > [Mac Notebooks: Caps Lock modified to reduce accidental activation](http://support.apple.com/kb/ht1192)

You must *firmly* press the key for half-a-tick longer than a normal keypress for it to be recognized.

We are [working on removing this delay](https://github.com/tekezo/NoEjectDelay/issues/1), but it may not be possible.

## Support

If you have any issues or suggestions, please [create a GitHub issue](https://github.com/pkamb/PowerKey/issues):

https://github.com/pkamb/PowerKey/issues