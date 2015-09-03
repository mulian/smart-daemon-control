SmartDaemonControllView = require './smart-daemon-controll-view'
{CompositeDisposable} = require 'atom'
ScanDeamons = require './scan-deamons'

module.exports = SmartDaemonControll =
  config: require '../config.json' #the config is ready, if you already install
  defaultConfig: {} #this is the defaultConfig for Global Settings

  smartDaemonControllView: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable

    @scanDeamons = new ScanDeamons(@defaultConfig)
    @smartDaemonControllView = new SmartDaemonControllView(state.smartDaemonControllViewState,@scanDeamons)

    # Register command to scan
    @subscriptions.add atom.commands.add 'atom-workspace',
        'launchd-controll:scan-daemons' : ()=> @scanDeamons.run()
        'launchd-controll:scan-reset' : ()=> @scanDeamons.reset()

  consumeStatusBar: (statusBar) ->
    @smartDaemonControllView.initialize statusBar
    @smartDaemonControllView.attach()

  test:() ->
    #div = document.createElement('div')
    #atom.workspace.addBottomPanel(item: div,visible: true)

  deactivate: ->
    @subscriptions.dispose()
    @smartDaemonControllView.detach()

  serialize: ->
    smartDaemonControllViewState: @smartDaemonControllView.serialize()
