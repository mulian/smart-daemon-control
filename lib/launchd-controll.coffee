LaunchdControllView = require './launchd-controll-view'
{CompositeDisposable} = require 'atom'
ScanServices = require './ScanServices'

module.exports = LaunchdControll =
  #the config is ready, if you already install
  config: require '../config.json'
  #this is the defaultConfig for Global Settings
  defaultConfig: {}

  launchdControllView: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @scanServices = new ScanServices(@defaultConfig)
    @launchdControllView = new LaunchdControllView(state.launchdControllViewState,@scanServices)
    # Register command to scan
    @subscriptions.add atom.commands.add 'atom-workspace',
        'launchd-controll:scan-daemons' : ()=> @scanServices.run()
        'launchd-controll:scan-reset' : ()=> @scanServices.reset()

  consumeStatusBar: (statusBar) ->
    @launchdControllView.initialize statusBar
    @launchdControllView.attach()

  test:() ->
    #div = document.createElement('div')
    #atom.workspace.addBottomPanel(item: div,visible: true)

  deactivate: ->
    @subscriptions.dispose()
    @launchdControllView.detach()

  serialize: ->
    launchdControllViewState: @launchdControllView.serialize()
