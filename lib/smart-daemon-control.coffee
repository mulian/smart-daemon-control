{CompositeDisposable} = require 'atom'

DaemonManagement = require "./daemon-management"

module.exports = SmartDaemonControl =
  subscriptions: null

  config :
    statusbarOrientation:
      type: 'string'
      enum: ['left','right']
      default: 'left'
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

  consumeStatusBar: (statusBar) ->
    @daemonManagement.consumeStatusBar statusBar

  deactivate: ->
    @subscriptions.dispose()
    @daemonManagement.destroy()

  #TODO: use serialize
  serialize: ->
    #smartDaemonControlViewState: @smartDaemonControlView.serialize()
