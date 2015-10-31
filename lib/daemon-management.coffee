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

  emitter: null

  constructor: (@eventBus) ->
    @regEventBus()
    @daemonControl = new DaemonControl @eventBus
    @daemonItemConfigureView = new DaemonItemConfigureView @eventBus
    @daemonItemConfigureView.attach(this)

    @rootPackageDir = atom.packages.loadedPackages[packageName].path

    @scanDeamons = new ScanDeamons(@eventBus)
    @daemonStatusBarContainerView = new DaemonStatusBarContainerView @eventBus


    # @createDamonsJsonIfNotExist()
    # @loadDaemonItems()

    @daemonAddWizard = new DaemonAddWizard(@eventBus) #test
    @eventBus.emit "get-subscription", (@subscriptions) => #to set @subscription from smart-daemon-control

  regEventBus: ->
    # @eventBus.on "daemon-management-add-daemon", @addDaemon
    @eventBus.on "daemon-management-new-daemon", @newDaemon #TODO add to daemonItemCollection
    # @eventBus.on "daemon-management-remove-daemon", @removeDaemon

  consumeStatusBar: (statusBar) ->
    @daemonStatusBarContainerView.initialize statusBar
    @daemonStatusBarContainerView.attach()


  # createDamonsJsonIfNotExist: ->
  #   @daemonsFile = new File "#{@rootPackageDir}/daemons.json"
  #   #console.log "create: #{@daemonsFile.create()} isFile: #{@daemonsFile.isFile()} exists: #{@daemonsFile.existsSync()}"
  #   if not @daemonsFile.existsSync()
  #     @daemonsFile.create()
  #     @daemonsFile.writeSync "{}"

  # loadDaemonItems: () ->
  #   @daemonItems = require "../daemons.json"
  #   highestKey = 0
  #   for itemKey,item of @daemonItems
  #     @setDaemonItemCommand item
  #     @daemonStatusBarContainerView.addDaemonItem item
  #     highestKey=itemKey if itemKey>highestKey
  #   @increment = parseInt(highestKey)+1

  refreshDaemonItem: (item) ->
    @saveDaemonItems()
    @daemonStatusBarContainerView.items[item.id].refresh()

  # saveDaemonItems: () ->
  #   console.log "save"
  #   @daemonsFile.write JSON.stringify(@daemonItems,null,4)

  addDaemon : (item) =>
    if item instanceof DaemonItem
      #TODO: check if similar Daemon already there by daemon.cmdRun. If yes: ask for add similar Daemon
      @eventBus.emit 'DaemonItemCollection.add', item
      @daemonStatusBarContainerView.addDaemonItem item #TODO add to EventBus
    else if item instanceof Array
      for i in item
        @addDaemon i


  showItemConfig : (item) => #TODO add to EventBus
    @daemonItemConfigureView.load item
    @daemonItemConfigureView.show()

  newDaemon: ->
    newD = new DaemonItem {name: "New"}
    @addDaemon newD
    @eventbus.emit 'DaemonItemConfigureView.show', newD

  removeDaemon: (daemonItem) ->
    @daemonStatusBarContainerView.removeDaemon daemonItem #TODO add to EventBus
    @eventBus.emit 'DaemonItemCollection.remove', daemonItem

  destroy: ->
    @daemonStatusBarContainerView.detach()
    for @daemonItem in @daemonItems
      @daemonItem.destroy()
