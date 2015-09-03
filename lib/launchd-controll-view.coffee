$ = jQuery = require 'jquery'
DaemonControll = require "./daemon-controll"
DaemonIconView = require "./daemon-icon-view"

module.exports =
class LaunchdControllView
  element : null
  daemonControll : null
  icons : []

  constructor: (@serializedState) ->
    #Create root element
    @element = $("<div/>",
      class: "inline-block launchd-controll",
    )
    # @element = document.createElement('div')
    # @element.className = "inline-block"
    # @element.classList.add('launchd-controll')
    @daemonControll = new DaemonControll()

  initialize: (@statusBar) ->
    console.log "add"
    for key,obj of atom.config.get('launchd-controll')
      console.log "add #{key}"
      icon = new DaemonIconView(@serializedState,key,obj.path,@daemonControll)
      @icons.push icon
      @element.append icon.element

  hide: ->
    @element.className = 'hidden'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  attach: ->
    @tile = @statusBar.addRightTile(item: @element, priority: 20)

  detach: ->
    @tile.destroy()

  #attach: ->
    #document.querySelector("status-bar").addLeftTile(item: this, priority: 100)
