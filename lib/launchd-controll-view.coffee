$ = jQuery = require 'jquery'
DaemonControll = require "./daemon-controll"
DaemonIconView = require "./daemon-icon-view"

module.exports =
class LaunchdControllView
  element : null
  daemonControll : null
  icons : []

  constructor: (@serializedState,@scannServices) ->
    #Create root element
    @element = $("<div/>",
      class: "inline-block launchd-controll",
    )
    # @element = document.createElement('div')
    # @element.className = "inline-block"
    # @element.classList.add('launchd-controll')
    @showScanButton() if !@scannServices.succesfulScan()
    @daemonControll = new DaemonControll()

  showScanButton: () ->
    @scanButton = $("<span/>",
      text: "Scan Daemons now"
      class: "scanButton"
    ).click ()=>
      @scanButton.text "reload Atom"
      @scannServices.run()
      @scanButton.click = null
    @element.append @scanButton

  initialize: (@statusBar) ->
    for key,obj of atom.config.get('launchd-controll')
      obj.key = key
      icon = new DaemonIconView(@serializedState,obj,@daemonControll)
      @icons.push icon
      @element.append icon.element

  hide: ->
    @element.addClass 'hidden'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  attach: ->
    @tile = @statusBar.addRightTile(item: @element, priority: 20)

  detach: ->
    @tile.destroy()

  #attach: ->
    #document.querySelector("status-bar").addLeftTile(item: this, priority: 100)
