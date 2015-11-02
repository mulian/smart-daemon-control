## next version
* add Modal Panel for daemons like currently in statusbar
  * Add key to open this Modal Panel
  * add Settings item to deaktivate statusbar
  * define keys for modal panel (1-9-0 and a-z)
  * show all Daemons with hide option
  * sort
* Add Daemon Wizard (with modal-file-manager)
* Daemon Edit Page
  * remove hide option

## 0.8.3 - next Bugfix: atom's state
* Fix problems with atom's state
  * Thanks for testing aitorllj93 !

## 0.8.2 - Fix secound bug of issue #2
* Fix daemonItemCollection==undefined

## 0.8.1 - Bugfix jQuery
* Bugfix jQuery

## 0.8.0 - runtime improvements
* Use an Eventbus (Emitter) for Daemons control
* Add checkDeamon interval to settings
* Use atoms state instaed of json file to save daemons
  * Only on this Release: transform json to atoms state
    * will be removed in next version
* aktivate start with atom
* Daemon Edit Page
  * Atom Checkbox
  * fit input length
* The source code has been completely reworked.
* And many other fixes


## 0.7.3 - unpublished
* remove jQuery from dependencies and use jquery from atom-space-pen-views
* set default statusbar orientation to right
* fix windows open settings bug
* fix autohide DaemonItemConfigureView for windows
* fix daemons.json init on update (for the next versions)
* add Debian-Scan-Algorithm
* check after start/stop Daemon if it is on/off

## 0.7.2 - Bugfix ...
* fix: backspace issue on item configuration
* add yes/no question before delete item
* add settings to position the DaemonStatusBarContainer in your statusbar

## 0.7.0 - No Atom Restart
* no more need to restart - i build an own Configuration Item. Now, the atom-config is only for static configurations.

## 0.1.0 - First Release
* Mac OS X: scan /usr/local/opt/ for Daemons andoo add them
* Start/Stop Daemons with one click in your Atom status-bar
* Register your Daemons in Config
