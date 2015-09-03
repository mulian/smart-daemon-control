{Directory,File} = require 'atom'
packageName = require('../package.json').name
CSON = require('cson')
installTimeOut = null

clone = (obj) ->
  return obj if null == obj || "object" != typeof obj
  copy = obj.constructor();
  for key,value in obj
    copy[key] = value if obj.hasOwnProperty key
  copy

module.exports =
class ScanDeamons
  rootPackageDir : null
  config : null
  constructor: (@defaultConfig) ->
    @rootPackageDir = atom.packages.loadedPackages[packageName].path
  run: () ->
    @config = clone @defaultConfig
    if process.platform == "darwin" #mac
      #console.log process.platform
      dir = new Directory('/usr/local/opt/')
      if dir.isDirectory() #brew
        @searchBrewPlist dir

    else if process.platform == "win32" #win
      null
      #console.log process.platform

  searchBrewPlist: (dir) ->
    re = /\.plist$/
    searchPlist = (dir) =>
      dir.getEntries (err,entries) =>
        for entrie in entries
          if entrie.isDirectory()
            searchPlist entrie
          else
            if re.exec(entrie.getBaseName()) != null
              regNewPlist entrie
    regNewPlist = (file) =>
      #console.log "Servicename: #{file.getParent().getBaseName()}, filename: #{file.path}"
      @addEntryToConfig file.getParent().getBaseName(), file.path
    #console.log "scan dir for *.plist"
    searchPlist dir

  addEntryToConfig: (serviceName,fileName) ->
    @config[serviceName] =
      type: 'object'
      properties:
        "path":
          type: 'string'
          default: fileName
        "hide":
          type: 'boolean'
          default: false
        "autostart":
          type: 'boolean'
          default: false
    @saveToConfig()

  saveToConfig: ->
    file = new File("#{@rootPackageDir}/config.json")
    file.write JSON.stringify(@config,null,4)
    clearTimeout installTimeOut
    installTimeOut = setTimeout =>
      @postInstall()
    , 100

  #It is installed, if more then one Service are registrated.
  succesfulScan: ->
    if @config == null #with config
      configEntry = atom.config.get(packageName)
      if configEntry?
        Object.keys(@defaultConfig).length < Object.keys(configEntry).length
      else false
    else Object.keys(@defaultConfig).length < Object.keys(@config).length

  postInstall : ->
    if @succesfulScan()
      atom.notifications.addInfo "Restart Atom!"
    else
      #nothing added!
      atom.notifications.addWarning "Nothing found to add."

  reset : ->
    #config hard reset, ist there a pretty way?
    userConfigCson = CSON.load atom.config.getUserConfigPath()
    delete userConfigCson["*"][packageName]
    userConfigFile = new File atom.config.getUserConfigPath()
    userConfigFile.write CSON.stringify userConfigCson

    #reset package config.json
    pageConfig = new File "#{@rootPackageDir}/config.json"
    pageConfig.write "{}"

    delete atom.config.settings[packageName] #not necessery
    atom.notifications.addSuccess "Scan reset successful, restart Atom"
