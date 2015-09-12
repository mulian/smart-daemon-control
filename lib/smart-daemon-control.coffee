{CompositeDisposable} = require 'atom'

DaemonManagement = require "./daemon-management"
#Test = require "./views/check-list-view"
#Test2 = require "./views/select-modal-view"

module.exports = SmartDaemonControl =
  subscriptions: null

  config :
    statusbarOrientation:
      type: 'string'
      enum: ['left','right']
      default: 'right'
    priority:
      type: 'integer'
      default: 300
      minimum: 0

  activate: (@state) ->
    #TODO: use state...
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @daemonManagement = new DaemonManagement(this)
    # Register command
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:scan-daemons' : ()=> @daemonManagement.scanDeamons.run()
      'smart-daemon-control:new-daemon' : ()=> @daemonManagement.newDaemon()
      #'smart-daemon-control:test' : ()=> @test()
      #'smart-daemon-control:tes2t' : ()=> @test2()

  # test: ->
  #   new Test()
  #
  # test2: ->
  #   new Test2()

  consumeStatusBar: (statusBar) ->
    @daemonManagement.consumeStatusBar statusBar

  deactivate: ->
    @subscriptions.dispose()
    @daemonManagement.destroy()

  #TODO: use serialize
  serialize: ->
    #smartDaemonControlViewState: @smartDaemonControlView.serialize()
