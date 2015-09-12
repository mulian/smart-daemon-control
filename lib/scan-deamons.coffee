{Directory} = require 'atom'
DaemonItem = require "./daemon-item"

module.exports =
class ScanDeamons
  scanFunction : null
  constructor: (@daemonManagement) ->
    @defineScanFunction()

  defineScanFunction: ->
    if process.platform == "darwina" #mac
      @scanFunction = ScanDaemonsBrew
    else #if /^win/.test(process.platform) #win
      #atom.notifications.addInfo "There is no scan algorithm for your #{process.platform} platform, plaese add this!"
      #atom.notifications.addInfo "Add manual daemons with CMD+SHIFT+P -> Smart Daemon Control: New Daemon"
      #@daemonManagement.newDaemon()
    #else if /^linux/.test(process.platform) #linux

  run: ->
    if @scanFunction?
      new @scanFunction(this)
    else atom.notifications.addInfo "There is no scan-algorithm for your OS #{process.platform} right now."

  thereIsScanDaemonForOs: ->
    if @scanFunction == null
      false
    else true

  addDaemon: (daemonName,filePath,fileNameWithoutAfterDot) ->
    #console.log fileNameWithoutAfterDot
    @daemonManagement.addDaemon new DaemonItem daemonName,"launchctl load #{filePath}",
                                                "launchctl unload #{filePath}","launchctl list",
                                                fileNameWithoutAfterDot, false, false, false
    atom.notifications.addInfo "#{daemonName} added"

#Scan Class for Brew
class ScanDaemonsBrew
  constructor: (@scanDeamons) ->
    dir = new Directory('/usr/local/opt/')
    if dir.isDirectory()
      atom.notifications.addInfo "Scan Brew like Daemons"
      @searchPlist dir

  searchPlist: (dir) ->
    re = /^([\w\.]+)\.plist$/
    searchPlist = (dir) =>
      dir.getEntries (err,entries) =>
        for entrie in entries
          if entrie.isDirectory()
            searchPlist entrie
          else
            result = re.exec(entrie.getBaseName())
            if result != null
              regNewPlist entrie, result[1]

    regNewPlist = (file,fileNameWithoutAfterDot) =>
      @scanDeamons.addDaemon file.getParent().getBaseName(), file.path, fileNameWithoutAfterDot
    searchPlist dir
