{Directory} = require 'atom'
DaemonItem = require "./daemon-item"

module.exports =
class ScanDeamons
  daemonItems : []
  installTimeOut : null
  constructor: (@smartDaemonControl) ->

  run: () ->
    if process.platform == "darwin" #mac
      #console.log process.platform
      dir = new Directory('/usr/local/opt/')
      if dir.isDirectory() #brew
        @searchPlist dir
    #TODO INFOs

    else if process.platform == "win32" #win
      null
      #console.log process.platform

  searchPlist: (dir) ->
    re = /\.plist$/
    searchPlist = (dir) =>
      dir.getEntries (err,entries) =>
        for entrie in entries
          #console.log entrie.getBaseName()
          if entrie.isDirectory()
            searchPlist entrie
          else
            if re.exec(entrie.getBaseName()) != null
              regNewPlist entrie
    regNewPlist = (file) =>
      #console.log "Servicename: #{file.getParent().getBaseName()}, filename: #{file.path}"
      @addEntryToConfig file.getParent().getBaseName(), file.path, file.getBaseName()
    #console.log "scan dir for *.plist"
    searchPlist dir

  addEntryToConfig: (daemonName,filePath,fileName) ->
    @smartDaemonControl.addDaemon new DaemonItem daemonName,"launchctl load #{filePath}",
                                                "launchctl unload #{filePath}","launchctl list #{filePath}",
                                                fileName, false, false, false
    atom.notifications.addInfo "#{daemonName} hinzugefügt"
