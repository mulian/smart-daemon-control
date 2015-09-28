{CompositeDisposable,Emitter} = require 'atom'

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

  activate: (state) ->
    @eventBus = new Emitter
    #TODO: use state...
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @daemonManagement = new DaemonManagement(@eventBus)
    # Register command
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:scan-daemons' : => @daemonManagement.scanDeamons.run()
      'smart-daemon-control:new-daemon' : => @daemonManagement.newDaemon()
      'smart-daemon-control:add-wizard' : => @daemonManagement.daemonAddWizard.run()
    @eventBus.on "get-subscription", (cb) =>
      cb @subscriptions
      #'smart-daemon-control:test' : ()=> @test()
      #'smart-daemon-control:tes2t' : ()=> @test2()

  # test: ->
  #   new Test()
  #
  # test2: ->
  #   new Test2()

  consumeStatusBar: (statusBar) -> #del?
    @daemonManagement.consumeStatusBar statusBar

  deactivate: ->
    @eventBus.emit "destroy"
    @subscriptions.dispose()
    @daemonManagement.destroy()
    @eventBus.dispose()

  #TODO: use serialize
  serialize: ->
    #see https://atom.io/docs/v0.186.0/advanced/serialization
    #require '../daemons.json'
    #smartDaemonControlViewState: @smartDaemonControlView.serialize()
