{View,$} = require 'atom-space-pen-views'
StatusBarItemView = require "./status-bar-item-view"
packageName = require('../package.json').name

module.exports =
class StatusBarContainerView extends View
  @content: ->
    @div class: "inline-block smart-daemon-control"
  #TODO: Drag and Drop DaemonStatusBarItemView to order
  element : null
  daemonControl : null
  items : {}

  constructor: (@statusBar) ->
    super

  regEventBus: ->
    @eb = eb.smartDaemonControl
    @eb.eb 'statusBarContainerView',{} =
      add: @addDaemonItem
      remove: @removeDaemon
    # eb('on',{thisArg:@}) 'SmartDaemonControl.StatusBarContainerView', {} =
    #   add: @addDaemonItem
    #   remove: @removeDaemon
    # @eventBus.on "status-bar-container-view:add", @addDaemonItem
    # @eventBus.on "status-bar-container-view:remove", @removeDaemon

  regConfOnDidChange: ->
    atom.config.onDidChange "#{packageName}.priority", => @attach()
    atom.config.onDidChange "#{packageName}.statusbarOrientation", => @attach()
    atom.config.onDidChange "#{packageName}.refresh", => @attach()

  initialize: ->
    @regEventBus()
    @regConfOnDidChange()
    # eb({thisArg:@}).SmartDaemonControl.DaemonItemCollection.get @addDaemonItem
    # @eventBus.emit 'daemon-item-collection:get', @addDaemonItem
    @attach()
    @eb.daemonItemCollection.get @addDaemonItem

  _refresh: ->
    @_refreshInterfall = setInterval =>
      @eb.daemonItemCollection.checkStates()
      # @eventBus.emit 'daemon-item-collection:checkStates'
    , @_refreshRateInSec*1000

  addAddDaemonButton: () ->
    @addButton = $("<span/>",
      text: "Add Daemon"
      class: "scan-button"
    ).click ()=>
      @eb.daemonItemCollection.new()
      # @eventBus.emit "new-daemon"
      @addButton.remove()
    $(@element).append @addButton

  addScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons"
      class: "scan-button"
    ).click ()=>
      # @eventBus.emit "scan-daemon-run"
      @eb.scanDaemons.run()
      #@daemonManagement.scanDeamons.run()
      @scanButton.remove()
    $(@element).append @scanButton

  addDaemonItem: (daemonItem) =>
    item = new StatusBarItemView(daemonItem)
    # @eventBus.emit 'daemon-item-collection:checkStates'
    @eb.daemonItemCollection.checkStates()
    @items[daemonItem.id] = item
    $(@element).append item.element
    @scanButton?.remove()
    @addButton?.remove()
  removeDaemon: (daemonItem) =>
    @items[daemonItem.id].element.remove()
    delete @items[daemonItem.id]

  # Attach to status-bar
  attach: ->
    chosenFunction = null
    switch atom.config.get("#{packageName}.statusbarOrientation")
      #when 'right'  then chosenFunction = @statusBar.addRightTile #no need
      when 'left'   then chosenFunction = @statusBar.addLeftTile
      else chosenFunction = @statusBar.addRightTile
    @tile = chosenFunction(item: @, priority: atom.config.get("#{packageName}.priority"))
    clearInterval @_refreshInterfall if @_refreshInterfall?
    @_refreshRateInSec = atom.config.get("#{packageName}.refresh")
    @_refresh() if @_refreshRateInSec!=0


  detach: ->
    @tile.destroy()
