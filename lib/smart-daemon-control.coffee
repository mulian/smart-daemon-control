{CompositeDisposable, Emitter} = require 'atom'
DaemonManagement = require './daemon-management'
DaemonItemCollection = require './daemon-item-collection'
DaemonControl = require './daemon-control'
DaemonItemConfigureView = require './daemon-item-configure-view'
StatusBarContainerView = require './status-bar-container-view'
# DaemonAddWizard = require "./daemon-add-wizard"
ScanDeamons = require './scan-deamons'

require 'e-bus'

module.exports = SmartDaemonControl =
  #config definition
  config :
    statusbarOrientation:
      title: 'Statusbar Orientation'
      type: 'string'
      enum: ['left','right']
      default: 'right'
    priority:
      title: 'Priority in statusbar'
      type: 'integer'
      default: 300
      minimum: 0
    refresh:
      title: 'Refresh rate in sec.'
      type: 'integer'
      default: 15
      minimum: 0
      description: 'Refresh rate of check Deamons in seconds, 0=off.'

  # atom call: will called on package init
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @eventBus = new Emitter
    #parse state or create new collection
    @daemonItemCollection =
      if state
        state.eventBus = @eventBus
        atom.deserializers.deserialize state
      else
        new DaemonItemCollection @eventBus
    if not @daemonItemCollection? #only because of issue #2
      @daemonItemCollection = new DaemonItemCollection @eventBus

    @initCommands()
    @initServices()

    # Run Daemon Management
    @daemonManagement = new DaemonManagement @eventBus

    # console.log "init ready?"
    # @eventBus.emit "EventsReady"

  initServices: ->
    @daemonControl = new DaemonControl @eventBus

    @daemonItemConfigureView = new DaemonItemConfigureView @eventBus

    @scanDeamons = new ScanDeamons @eventBus
    # @daemonAddWizard = new DaemonAddWizard @eventBus

  initCommands: ->
    @subscriptions.add atom.commands.add 'atom-workspace',
      'smart-daemon-control:scan-daemons' : => @scanDeamons.run()
      'smart-daemon-control:new-daemon' : => @daemonItemCollection.new()
      # 'smart-daemon-control:add-wizard' : => @daemonAddWizard.run()

  # atom call: init statusbar
  consumeStatusBar: (statusBar) ->
    @statusBarContainerView = new StatusBarContainerView @eventBus, statusBar

  # atom call: on package deactivate:
  deactivate: ->
    @eventBus.emit "destroy"
    @subscriptions.dispose()
    @statusBarContainerView.detach()
    @daemonManagement.destroy()
    @eventBus.dispose()
    eb('rm')('SmartDaemonControl')

  # atom call: save current daemonItems state
  serialize: ->
    @daemonItemCollection.serialize()
    # return undefined -> to test reset state
