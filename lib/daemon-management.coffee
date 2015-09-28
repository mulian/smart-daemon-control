DaemonItemConfigureView = require './daemon-item-configure-view'
ScanDeamons = require './scan-deamons'
DaemonItem = require "./daemon-item"
DaemonControl = require "./daemon-control"
packageName = require('../package.json').name
DaemonStatusBarContainerView = require './daemon-status-bar-container-view'
{Directory,File} = require 'atom'

DaemonAddWizard = require "./daemon-add-wizard"

module.exports =
class DaemonManagement
  DdemonStatusBarContainerView: null

  daemonItemConfigureView: null
  daemonItems: null
  rootPackageDir: null

  daemonsFile: null

  increment : 0

  constructor: (@smartDaemonControl) ->
    @subscriptions = @smartDaemonControl.subscriptions
    @daemonItemConfigureView = new DaemonItemConfigureView()
    @daemonItemConfigureView.attach(this)

    @rootPackageDir = atom.packages.loadedPackages[packageName].path

    @scanDeamons = new ScanDeamons(this)
    @daemonStatusBarContainerView = new DaemonStatusBarContainerView(@smartDaemonControl.state.smartDaemonControlViewState,this)
    @daemonControl = new DaemonControl()

    @createDamonsJsonIfNotExist()
    @loadDaemonItems()

    @daemonAddWizard = new DaemonAddWizard() #test

  consumeStatusBar: (statusBar) ->
    @daemonStatusBarContainerView.initialize statusBar
    @daemonStatusBarContainerView.attach()


  createDamonsJsonIfNotExist: ->
    @daemonsFile = new File "#{@rootPackageDir}/daemons.json"
    #console.log "create: #{@daemonsFile.create()} isFile: #{@daemonsFile.isFile()} exists: #{@daemonsFile.existsSync()}"
    if not @daemonsFile.existsSync()
      @daemonsFile.create()
      @daemonsFile.writeSync "{}"

  loadDaemonItems: () ->
    @daemonItems = require "../daemons.json"
    highestKey = 0
    for itemKey,item of @daemonItems
      @setDaemonItemCommand item
      @daemonStatusBarContainerView.addDaemonItem item
      highestKey=itemKey if itemKey>highestKey
    @increment = parseInt(highestKey)+1

  refreshDaemonItem: (item) ->
    @saveDaemonItems()
    @daemonStatusBarContainerView.items[item.id].refresh()

  saveDaemonItems: () ->
    console.log "save"
    @daemonsFile.write JSON.stringify(@daemonItems,null,4)

  addDaemon : (item) ->
    if item instanceof DaemonItem
      #TODO: check if similar Daemon already there by daemon.cmdRun. If yes: ask for add similar Daemon
      item.id = @increment
      @daemonItems[item.id] = item
      @setDaemonItemCommand item
      @saveDaemonItems()
      @daemonStatusBarContainerView.addDaemonItem item
      @increment++
    else if item instanceof Array
      for i in item
        @addDaemon i

  setDaemonItemCommand : (item) ->
    @subscriptions.add atom.commands.add 'atom-workspace',"smart-daemon-control:configure-#{item.name}", => @showItemConfig(item)

  showItemConfig : (item) ->
    @daemonItemConfigureView.load item
    @daemonItemConfigureView.show()

  newDaemon: ->
    newD = new DaemonItem {name: "New"}
    @addDaemon newD
    @showItemConfig newD

  removeDaemon: (daemonItem) ->
    @daemonStatusBarContainerView.removeDaemon daemonItem
    delete @daemonItems[daemonItem.id]
    @saveDaemonItems()

  destroy: ->
    @daemonStatusBarContainerView.detach()
    for @daemonItem in @daemonItems
      @daemonItem.destroy()
