{$} = require 'atom-space-pen-views'
DaemonStatusBarItemView = require "./daemon-status-bar-item-view"
packageName = require('../package.json').name

module.exports =
class DaemonStatusBarContainerView
  #TODO: Drag and Drop DaemonStatusBarItemView to order
  element : null
  daemonControl : null
  items : {}

  constructor: (@eventBus) ->
    @regEventBus()
    @regConfOnDidChange()
    @element = $("<div/>",
      class: "inline-block smart-daemon-control",
    )
    # no need?
    # if @daemonManagement.scanDeamons.thereIsScanDaemonForOs()
    #   @addScanButton()
    # else @addAddDaemonButton()

  regEventBus: ->
    @eventBus.on "statusbar-add-daemon-item", @addDaemonItem
    @eventBus.on "statusbar-remove-daemon-item", @removeDaemon

  regConfOnDidChange: ->
    atom.config.onDidChange "#{packageName}.priority", =>
      @attach()
    atom.config.onDidChange "#{packageName}.statusbarOrientation", =>
      @attach()

  initialize: (@statusBar) ->
    collection = @eventBus.emit 'DaemonItemCollection.get', @addDaemonItem
    # console.log collection

  addAddDaemonButton: () ->
    @addButton = $("<span/>",
      text: "Add Daemon"
      class: "scan-button"
    ).click ()=>
      @eventBus.emit "new-daemon"
      @addButton.remove()
    @element.append @addButton

  addScanButton: () -> #on reset/first install
    @scanButton = $("<span/>",
      text: "Scan Daemons"
      class: "scan-button"
    ).click ()=>
      @eventBus.emit "scan-daemon-run"
      #@daemonManagement.scanDeamons.run()
      @scanButton.remove()
    @element.append @scanButton


  addDaemonItem: (daemonItem) =>
    item = new DaemonStatusBarItemView(@eventBus, daemonItem)
    @items[daemonItem.id] = item
    @element.append item.element
    @scanButton?.remove()
    @addButton?.remove()
  removeDaemon: (daemonItem) =>
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
