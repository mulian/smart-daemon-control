DaemonControll = require "./daemon-controll"

module.exports =
class LaunchdControllView
  element : null
  daemonControll : null

  constructor: (@serializedState) ->
    #Create root element
    @element = document.createElement('div')
    @element.className = "inline-block"
    @element.classList.add('launchd-controll')
    @element.textContent = "TEST"

    @daemonControll = new DaemonControll()

  initialize: (@statusBar) ->
    console.log atom.config.get('launchd-controll')

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
