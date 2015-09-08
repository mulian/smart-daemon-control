$ = require 'jquery'
DaemonStatusBarItemView = require "./daemon-status-bar-item-view"
packageName = require('../package.json').name

module.exports =
class DaemonStatusBarContainerView
  #TODO: Drag and Drop DaemonStatusBarItemView to order
  element : null
  daemonControl : null
  items : {}

  constructor: (@serializedState,@daemonManagement) ->
    @element = $("<div/>",
      class: "inline-block smart-daemon-control",
    )
    @addScanButton()
    @regConfOnDidChange()

  regConfOnDidChange: ->
    atom.config.onDidChange "#{packageName}.priority", =>
      @attach()
    atom.config.onDidChange "#{packageName}.statusbarOrientation", =>
      @attach()

  initialize: (@statusBar) ->


  addScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons now"
      class: "scan-button"
    ).click ()=>
      @daemonManagement.scanDeamons.run()
      @removeScanButton()
    @element.append @scanButton
  removeScanButton: () ->
    @scanButton.remove()

  addDaemonItem: (daemonItem) ->
    item = new DaemonStatusBarItemView(@serializedState,daemonItem,@daemonManagement)
    @items[daemonItem.id] = item
    @element.append item.element
    @removeScanButton()
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
    chosenFunction = null
    switch atom.config.get("#{packageName}.statusbarOrientation")
      #when 'right'  then chosenFunction = @statusBar.addRightTile #no need
      when 'left'   then chosenFunction = @statusBar.addLeftTile
      else chosenFunction = @statusBar.addRightTile
    @tile = chosenFunction(item: @element, priority: atom.config.get("#{packageName}.priority"))
    #@tile = @statusBar.addLeftTile(item: @element, priority: 100)
    #console.log @statusBar

  detach: ->
    @tile.destroy()
