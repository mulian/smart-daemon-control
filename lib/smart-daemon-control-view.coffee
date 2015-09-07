$ = require 'jquery'
DaemonControlItemView = require "./daemon-control-item-view"
packageName = require('../package.json').name

module.exports =
class SmartDaemonControlView
  element : null
  daemonControl : null
  items : {}

  constructor: (@serializedState,@smartDaemonControl) ->
    @element = $("<div/>",
      class: "inline-block smart-daemon-control",
    )
    #@showScanButton() #if !@scannServices.succesfulScan()

  initialize: (@statusBar) ->

  showScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons now"
      class: "scan-button"
    ).click ()=>
      @scanButton.text "reload Atom"
      @scannServices.run()
      @scanButton.click = null
    @element.append @scanButton

  addDaemonItem: (daemonItem) ->
    item = new DaemonControlItemView(@serializedState,daemonItem,@smartDaemonControl)
    @items[daemonItem.id] = item
    @element.append item.element
  removeDaemon: (daemonItem) ->
    @items[daemonItem.id].element.remove()
    delete @items[daemonItem.id]

  hide: ->
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Attach to status-bar
  attach: ->
    @tile = @statusBar.addRightTile(item: @element, priority: 201)
    #@tile = @statusBar.addLeftTile(item: @element, priority: 100)
    #console.log @statusBar

  detach: ->
    @tile.destroy()
