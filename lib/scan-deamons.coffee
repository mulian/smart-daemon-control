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
    re = /^([\w\.]+)\.plist$/
    searchPlist = (dir) =>
      dir.getEntries (err,entries) =>
        for entrie in entries
          #console.log entrie.getBaseName()
          if entrie.isDirectory()
            searchPlist entrie
          else
            result = re.exec(entrie.getBaseName())
            if result != null
              regNewPlist entrie, result[1]
    regNewPlist = (file,fileNameWithoutAfterDot) =>
      #console.log "Servicename: #{file.getParent().getBaseName()}, filename: #{file.path}"
      @addEntryToConfig file.getParent().getBaseName(), file.path, fileNameWithoutAfterDot
    #console.log "scan dir for *.plist"
    searchPlist dir

  addEntryToConfig: (daemonName,filePath,fileNameWithoutAfterDot) ->
    #console.log fileNameWithoutAfterDot
    @smartDaemonControl.addDaemon new DaemonItem daemonName,"launchctl load #{filePath}",
                                                "launchctl unload #{filePath}","launchctl list",
                                                fileNameWithoutAfterDot, false, false, false
    atom.notifications.addInfo "#{daemonName} hinzugefügt"
