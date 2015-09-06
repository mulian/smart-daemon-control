SmartDaemonControlView = require './smart-daemon-control-view'
{CompositeDisposable} = require 'atom'
ScanDeamons = require './scan-deamons'
DaemonItemConfigureView = require './daemon-item-configure-view'
{Directory,File} = require 'atom'
packageName = require('../package.json').name
DaemonItem = require "./daemon-item"

module.exports = SmartDaemonControl =
  #config: require '../config.json' #the config is ready, if you already install
  rootPackageDir : null

  smartDaemonControlView: null
  subscriptions: null

  daemonItemConfigureView: null
  daemonItems: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @rootPackageDir = atom.packages.loadedPackages[packageName].path

    @scanDeamons = new ScanDeamons(this)
    @smartDaemonControlView = new SmartDaemonControlView(state.smartDaemonControlViewState,@scanDeamons)

    # Register command to scan
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:scan-daemons' : ()=> @scanDeamons.run()

    @daemonItemConfigureView = new DaemonItemConfigureView()
    @daemonItemConfigureView.attach(this)

    @loadDaemonItems()

  loadDaemonItems: () ->
    @daemonItems = require "../config.json"
    for itemKey,item of @daemonItems
      @setDaemonItemCommand item
  saveDaemonItems: () ->
    file = new File "#{@rootPackageDir}/config.json"
    file.write JSON.stringify(@daemonItems,null,4)
  addDaemon : (item) ->
    if item instanceof DaemonItem
      @daemonItems[item.name] = item
      @setDaemonItemCommand item
      @saveDaemonItems()
    else if item instanceof Array
      for i in item
        @addDaemon i
  setDaemonItemCommand : (item) ->
    @subscriptions.add atom.commands.add 'atom-workspace',"smart-daemon-control:configure-#{item.name}", => @showItemConfig(item)
  showItemConfig : (item) ->
    @daemonItemConfigureView.load item
    @daemonItemConfigureView.modalPanel.show()

  consumeStatusBar: (statusBar) ->
    @smartDaemonControlView.initialize statusBar
    @smartDaemonControlView.attach()

  toggleDaemonItemConfigureView:() ->
    if @daemonItemConfigureView.modalPanel.isVisible()
      @daemonItemConfigureView.modalPanel.hide()
    else
      @daemonItemConfigureView.modalPanel.show()

    #div = document.createElement('div')
    #atom.workspace.addBottomPanel(item: div,visible: true)

  deactivate: ->
    @subscriptions.dispose()
    @smartDaemonControlView.detach()
    for @daemonItem in @daemonItems
      @daemonItem.destroy()
    @saveDaemonItems()

  serialize: ->
    smartDaemonControlViewState: @smartDaemonControlView.serialize()
