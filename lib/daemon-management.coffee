

DaemonItem = require "./daemon-item"
packageName = require('../package.json').name

{Directory,File,CompositeDisposable} = require 'atom'


# Will be deleted in next version!
module.exports =
class DaemonManagement
  constructor: (@eventBus) ->
    @subscriptions = new CompositeDisposable
    @regEventBus()

    #will be deletet in next version
    @rootPackageDir = atom.packages.loadedPackages[packageName].path
    @transportJsonToStateIfExist()

  regEventBus: ->
    @eventBus.on "destroy", @destroy

  #Test:
  # {"1":{"name":"mysql","cmdRun":"launchctl load /usr/local/opt/mysql/homebrew.mxcl.mysql.plist","cmdStop":"launchctl unload /usr/local/opt/mysql/homebrew.mxcl.mysql.plist","cmdCheck":"launchctl list","strCheck":"homebrew.mxcl.mysql","autorun":true,"id":2}}

  # will be deletet in next version
  transportJsonToStateIfExist: ->
    daemonsFile = new File "#{@rootPackageDir}/daemons.json"
    # Check if there is an daemon.json from prev. version
    if daemonsFile.existsSync()
      console.log  "Transform JSON to State"
      daemons = require '../daemons.json'
      # pipe it to state
      for k,item of daemons
        @eventBus.emit "daemon-item-collection:add", item
      # and set file to an emtpy object
      daemonsFile.writeSync "{}"

  destroy: =>
    @subscriptions.dispose()
