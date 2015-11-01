

DaemonItem = require "./daemon-item"
packageName = require('../package.json').name

{Directory,File,CompositeDisposable} = require 'atom'



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




  # Check if there is an daemon.json from prev. version
  # will be deletet in next version
  transportJsonToStateIfExist: ->
    daemonsFile = new File "#{@rootPackageDir}/daemons.json"
    if daemonsFile.existsSync()
      daemons = require '../daemons.json'
      # pipe it to state
      for key, obj of daemons
        delete obj.id
        @eventBus.emit "DaemonItemCollection.add", obj
      # and set file to an emtpy object
      daemonsFile.writeSync "{}"

  destroy: =>
    @subscriptions.dispose()
