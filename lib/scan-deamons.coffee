{Directory} = require 'atom'
DaemonItem = require "./daemon-item"
{BufferedProcess} = require 'atom'

class ScanDaemons #extends this
  name : null   #OS name
  dirPath: null #dir path of deamon start/stop
  re: null      #search Regular Expression
  formatDaemonItem: (file) -> #transform Filename to Daemon Name & run-/stop-/check-Daemon

  constructor: (@scanDaemons) ->
    @info()
    @startScan()

  startScan: (dirPath=@dirPath) -> #run this
    dir = new Directory(dirPath)
    if dir.isDirectory()
      @scanForFile dir
    else atom.notifications.addInfo "Could not Scan with #{@name}-algorithm"
  scanForFile: (dir) ->
    dir.getEntries (err,entries) =>
      for entrie in entries
        if not entrie.isDirectory()
          result = @re.exec entrie.getBaseName()
          if result != null
            @scanDaemons.addDaemon @formatDaemonItem entrie
            #@regNewDaemon entrie, result[1]
        else @scanForFile entrie #scan subfolder
  info : ->
    atom.notifications.addInfo "Scan #{@name} Daemons"

  checkDir: ->
    dir = new Directory(dirPath)
    return dir.exists() and dir.isDirectory()
  #regNewDaemon = (file,fileNameWithoutAfterDot) =>
    #@scanDeamons.addDaemon file.getParent().getBaseName(), file.path, fileNameWithoutAfterDot

checkLinuxDist = ->
  #check for Debian
  dir = new Directory "/etc/init.d/"
  return "debian" if dir.exists() and dir.isDirectory()
  #next RedHat, CentOS, Suse, ...

#Scan Class for (Debian)/Ubuntu
class ScanDaemonsDebian extends ScanDaemons
  name: "Debian like (Ubuntu)"
  dirPath: "/etc/init.d/"
  re: /^([\w\.]+)$/ #all
  formatDaemonItem: (file) ->
    return new DaemonItem
      name: file.getBaseName()
      cmdRun: "#{file.path} start"
      cmdStop: "#{file.path} stop"
      cmdCheck: "#{file.path} status"
      strCheck: "is running"

#Scan Class for Brew
class ScanDaemonsBrew extends ScanDaemons
  name: "Brew"
  dirPath: "/usr/local/opt/"
  re: /^([\w\.]+)\.plist$/
  formatDaemonItem: (file) ->
    return new DaemonItem
      #name: "bla"
      name: file.getParent().getBaseName()
      cmdRun: "launchctl load #{file.path}"
      cmdStop: "launchctl unload #{file.path}"
      cmdCheck: "launchctl list"
      strCheck: @re.exec file.getBaseName()[1]

module.exports =
class ScanDeamons
  scanFunction : null
  constructor: (@daemonManagement) ->
    @defineScanFunction()

  defineScanFunction: ->
    if process.platform == "darwin" #mac
      @scanFunction = ScanDaemonsBrew
    else if /^linux/.test(process.platform) #linux
      switch checkLinuxDist()
        when "debian" then @scanFunction = ScanDaemonsDebian
    #else if /^win/.test(process.platform) #win
      #atom.notifications.addInfo "There is no scan algorithm for your #{process.platform} platform, plaese add this!"
      #atom.notifications.addInfo "Add manual daemons with CMD+SHIFT+P -> Smart Daemon Control: New Daemon"
      #@daemonManagement.newDaemon()

  run: ->
    if @scanFunction?
      new @scanFunction(this)
    else
      #console.log process
      atom.notifications.addInfo "There is no scan-algorithm for your OS #{process.platform} right now."

  thereIsScanDaemonForOs: ->
    if @scanFunction == null
      false
    else true

  addDaemon: (daemonItem) ->
    @daemonManagement.addDaemon daemonItem
    atom.notifications.addInfo "#{daemonItem.name} added"
