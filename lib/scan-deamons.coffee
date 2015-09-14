{Directory} = require 'atom'
DaemonItem = require "./daemon-item"
{BufferedProcess} = require 'atom'

module.exports =
class ScanDeamons
  scanFunction : null
  constructor: (@daemonManagement) ->
    @defineScanFunction()

  defineScanFunction: ->
    if process.platform == "darwin" #mac
      @scanFunction = ScanDaemonsBrew
    else if /^linux/.test(process.platform) #linux
      @isLinuxDistribution "Ubuntu", =>
        @scanFunction = ScanDaemonsUbuntu
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

  addDaemon: (daemonName,filePath,fileNameWithoutAfterDot) ->
    #console.log fileNameWithoutAfterDot
    @daemonManagement.addDaemon new DaemonItem daemonName,"launchctl load #{filePath}",
                                                "launchctl unload #{filePath}","launchctl list",
                                                fileNameWithoutAfterDot, false, false, false
    atom.notifications.addInfo "#{daemonName} added"

  isLinuxDistribution: (name,callback) -> #other better solution?
    command = "uname"
    args = ["-v"]
    alreadyGetCheckString = false
    stdout = (output) ->
      if output.indexOf(name) >- 1
        alreadyGetCheckString = true
    exit = (code) ->
      callback() if alreadyGetCheckString
    process = new BufferedProcess({command, args, stdout, exit})

class ScanDaemons #extends this
  name : ""   #replace
  init : null # replace

  constructor: (@scanDaemons) ->
    @init()
    @info()

  startScan: (dirUrl,re) -> #run this
    dir = new Directory(dirUrl)
    @scanForFile dir, re if dir.isDirectory()
  scanForFile = (dir,re) ->
    dir.getEntries (err,entries) =>
      for entrie in entries
        if not entrie.isDirectory()
          result = re.exec entrie.getBaseName()
          if result != null
            @regNewDaemon entrie, result[1]
        else @scanForFile entrie #scan subfolder

  regNewDaemon = (file,fileNameWithoutAfterDot) => #TODO: change format
    @scanDeamons.addDaemon file.getParent().getBaseName(), file.path, fileNameWithoutAfterDot

  info : ->
    atom.notifications.addInfo "Scan #{@name} Daemons"
#Scan Class for (Debian)/Ubuntu
class ScanDaemonsUbuntu extends ScanDaemons
  name: "Brew"
  init: ->
    @startScan "/usr/local/opt/", /^([\w\.]+)\.plist$/

#Scan Class for Brew
class ScanDaemonsBrew extends ScanDaemons
  name: "Brew"
  init: ->
    @startScan "/usr/local/opt/", /^([\w\.]+)\.plist$/
