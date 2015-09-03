$ = require 'jquery'
DaemonControll = require "./daemon-controll"
DaemonControllItemView = require "./daemon-controll-item-view"

module.exports =
class SmartDaemonControllView
  element : null
  daemonControll : null
  items : []

  constructor: (@serializedState,@scannServices) ->
    @element = $("<div/>",
      class: "inline-block launchd-controll",
    )
    @showScanButton() if !@scannServices.succesfulScan()
    @daemonControll = new DaemonControll()

  showScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons now"
      class: "scanButton"
    ).click ()=>
      @scanButton.text "reload Atom"
      @scannServices.run()
      @scanButton.click = null
    @element.append @scanButton

  initialize: (@statusBar) -> #init the Daemon Item
    for key,obj of atom.config.get('launchd-controll')
      obj.key = key
      item = new DaemonControllItemView(@serializedState,obj,@daemonControll)
      @items.push item
      @element.append item.element

  hide: ->
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Attach to status-bar
  attach: ->
    @tile = @statusBar.addRightTile(item: @element, priority: 20)

  detach: ->
    @tile.destroy()
