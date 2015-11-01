{View,$} = require 'space-pen'
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

  constructor: (@eventBus,@statusBar) ->
    super
    @regEventBus()
    @regConfOnDidChange()

  regEventBus: ->
    @eventBus.on "status-bar-container-view:add", @addDaemonItem
    @eventBus.on "status-bar-container-view:remove", @removeDaemon

  regConfOnDidChange: ->
    atom.config.onDidChange "#{packageName}.priority", =>
      @attach()
    atom.config.onDidChange "#{packageName}.statusbarOrientation", =>
      @attach()

  initialize: ->
    @eventBus.emit 'daemon-item-collection:get', @addDaemonItem
    @_refresh()

  _refresh: ->
    @eventBus.emit 'daemon-item-collection:checkStates'
    setInterval =>
      @eventBus.emit 'daemon-item-collection:checkStates'
    , 15*1000

  addAddDaemonButton: () ->
    @addButton = $("<span/>",
      text: "Add Daemon"
      class: "scan-button"
    ).click ()=>
      @eventBus.emit "new-daemon"
      @addButton.remove()
    $(@element).append @addButton

  addScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons"
      class: "scan-button"
    ).click ()=>
      @eventBus.emit "scan-daemon-run"
      #@daemonManagement.scanDeamons.run()
      @scanButton.remove()
    $(@element).append @scanButton


  addDaemonItem: (daemonItem) =>
    item = new StatusBarItemView(@eventBus, daemonItem)
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

  detach: ->
    @tile.destroy()
