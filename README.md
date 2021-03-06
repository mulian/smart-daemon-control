# smart-daemon-control package

Easy manage and control your development daemons like PHP, Apache, Nginx, MySql,... in your status bar.<br>

![Preview](https://raw.githubusercontent.com/mulian/smart-daemon-control/master/preview.png)
#Scan algorithm
Only for Mac OS X with brew and Debian Linux.

Other OS -> use Add new Daemon.

Note: Debian needs root (sudo) privileges for Atom.


## Install Steps
1. Install smart-daemon-control
 * Terminal: `apm install smart-daemon-control`
 * Atom: Preferences -> install -> search "smart daemon control" -> install
2. Scan your installed Daemons
 * Click on "Scan Daemons now" on right bottom StatusBar, if there is less then 1 demon added only
 * [⌘+⇧+P] and choose "Smart Daemon Controll: Scan Daemons"
 * Menu Bar: Packages -> Smart Daemon Control -> Scan Daemons
4. See your Daemons on right bottom (status-bar right)
 * Start, stop your Daemons with only **ONE CLICK**

## Add new Daemon (necessary for all os without scan algorithm)
1. Create new Item
  * [⌘+⇧+P] and choose "Smart Daemon Controll: New Daemon"
  * Menu Bar: Packages -> Smart Daemon Control -> New Daemon
2. Type all necessary Informations
  * daemon name: your daemon name
  * run cmd: the Terminal Command to run this Daemon
  * stop cmd: the Terminal Command to stop this Daemon
  * check cmd: the Terminal Command to get a list with all running daemons
  * check str.: the daemon string in the return of check command if it contains the string -> daemon is on else -> off
  * hide: hides your selected daemon in status bar.
    * To reshow this daemon use [⌘+⇧+P] and choose "Smart Daemon Controll: Configure <yourDaemonName>" and uncheck hide
  * start with atom: not working right now
  * start with this project: not working right now
3. ready to use in your status bar

## Edit Daemon
1. Open Daemon Edit Panel
  * dbl-click on Daemon entry in your status bar
  * [⌘+⇧+P] and choose "Smart Daemon Controll: Configure <yourDaemonName>"
2. Edit
3. ready to use in your status bar

## Delete Daemon
1. Open Daemon Edit Panel (see above)
2. Click Delete Daemon

## Theme Issue
For [issue #4](https://github.com/mulian/smart-daemon-control/issues/4), there are now fallback Colors.
If your theme will not define the default Colors, smart-daemon-control will now work fine. BUT maybe it looks bad.
