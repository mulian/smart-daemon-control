SmartDaemonControlView = require './smart-daemon-control-view'
{CompositeDisposable} = require 'atom'
ScanDeamons = require './scan-deamons'
DaemonItemView = require './daemon-item-view'

module.exports = SmartDaemonControl =
  config: require '../config.json' #the config is ready, if you already install
  defaultConfig: {} #this is the defaultConfig for Global Settings

  smartDaemonControlView: null
  subscriptions: null

  daemonItem: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable

    @scanDeamons = new ScanDeamons(@defaultConfig)
    @smartDaemonControlView = new SmartDaemonControlView(state.smartDaemonControlViewState,@scanDeamons)

    # Register command to scan
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:test': ()=> @test()
      'smart-daemon-control:scan-daemons' : ()=> @scanDeamons.run()
      'smart-daemon-control:scan-reset' : ()=> @scanDeamons.reset()

    @daemonItem = new DaemonItemView()
    @daemonItem.attach()

  consumeStatusBar: (statusBar) ->
    @smartDaemonControlView.initialize statusBar
    @smartDaemonControlView.attach()

  test2:() ->
    console.log "test2"
    if @daemonItem.modalPanel.isVisible()
      @daemonItem.modalPanel.hide()
    else
      @daemonItem.modalPanel.show()

  test:() ->
    str = "blubb"
    @subscriptions.add atom.commands.add 'atom-workspace',"smart-daemon-control:test2#{str}", ()=>
      @test2()
    @daemonItem.aus()
    console.log "test"

    #div = document.createElement('div')
    #atom.workspace.addBottomPanel(item: div,visible: true)

  deactivate: ->
    @subscriptions.dispose()
    @smartDaemonControlView.detach()

  serialize: ->
    smartDaemonControlViewState: @smartDaemonControlView.serialize()
