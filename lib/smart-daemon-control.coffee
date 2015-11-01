{CompositeDisposable,Emitter} = require 'atom'
DaemonManagement = require './daemon-management'
DaemonItemCollection = require './daemon-item-collection'
DaemonControl = require './daemon-control'
DaemonItemConfigureView = require './daemon-item-configure-view'
StatusBarContainerView = require './status-bar-container-view'
DaemonAddWizard = require "./daemon-add-wizard"
ScanDeamons = require './scan-deamons'

module.exports = SmartDaemonControl =
  #config definition
  config :
    statusbarOrientation:
      type: 'string'
      enum: ['left','right']
      default: 'right'
    priority:
      type: 'integer'
      default: 300
      minimum: 0
    refresh:
      type: 'integer'
      default: 15
      minimum: 0
      description: 'Refresh rate of check Deamons in seconds, 0=off'

  # outside call: will called on package init
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @eventBus = new Emitter
    #parse state or create new collection
    @daemonItemCollection =
      if state
        atom.deserializers.deserialize state
      else
        new DaemonItemCollection()
    @daemonItemCollection.addEventBus @eventBus

    @initCommands()

    @initServices()

    # Run Daemon Management
    @daemonManagement = new DaemonManagement @eventBus

    console.log "init ready?"
    @eventBus.emit "EventsReady"

  initServices: ->
    @daemonControl = new DaemonControl @eventBus

    @daemonItemConfigureView = new DaemonItemConfigureView @eventBus

    @scanDeamons = new ScanDeamons @eventBus
    @daemonAddWizard = new DaemonAddWizard @eventBus

  initCommands: ->
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:scan-daemons' : => @scanDeamons.run()
      'smart-daemon-control:new-daemon' : => @daemonItemCollection.new()
      'smart-daemon-control:add-wizard' : => @daemonAddWizard.run()

  # outside call: init statusbar
  consumeStatusBar: (statusBar) ->
    @statusBarContainerView = new StatusBarContainerView @eventBus, statusBar

  # outside call: on package deactivate:
  deactivate: ->
    @eventBus.emit "destroy"
    @subscriptions.dispose()
    @statusBarContainerView.detach()
    @daemonManagement.destroy()
    @eventBus.dispose()

  # outside call: save current daemonItems state
  serialize: ->
    @daemonItemCollection.serialize()
