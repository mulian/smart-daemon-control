packageName = require('../package.json').name
# {$} = require 'atom-space-pen-views'
{View,$} = require 'space-pen'

module.exports =
class StatusBarItemView #TODO: add class View
  constructor : (@eventBus,@daemonItem) ->
    @_reqEventBus()
    @status = false
    @isInProgress = false
    @element = $("<span/>",
      class : 'smart-daemon-control-item load'
      text : @daemonItem.name
    )
    @_reqClick()
    @checkHide()

  _dblclickTimeout : null
  _reqClick: ->
    @element.click (event) =>
      if @_dblclickTimeout == null
        @_dblclickTimeout = setTimeout =>
          @toggle()
          @_dblclickTimeout = null
        , 200
      else
        clearTimeout @_dblclickTimeout
        @_dblclickTimeout=null
        @showConfig()

  _reqEventBus: ->
    @eventBus.on "status-bar-item-view:remove", (item) => @remove() if @_amI item #delete?
    @eventBus.on "status-bar-item-view:hide", (item) => @hide() if @_amI item
    @eventBus.on "status-bar-item-view:show", (item) => @show() if @_amI item

    @eventBus.on "status-bar-item-view:aktivate", (item) => @setRunning() if @_amI item
    @eventBus.on "status-bar-item-view:deaktivate", (item) => @setNotRunning() if @_amI item

  _amI: (item) ->
    return true if item.id==@daemonItem.id
    return false

  removeMe: ->
    $(@element).remove()

  showConfig: () ->
    @eventBus.emit "daemon-item-configure-view:show", @daemonItem

  checkHide : () ->
    if @daemonItem.hide
      @hide()
    else @show()

  setRunning : () =>
    @element.removeClass "off load"
    @element.addClass "on"
    @status=true
    @isInProgress=false
  setNotRunning : () =>
    @element.removeClass "on load"
    @element.addClass "off"
    @status=false
    if @daemonItem.autorun
      @start()
      @daemonItem.autorun=false
    @isInProgress=false
  setInPgrogress : () =>
    @isInProgress=true
    @element.removeClass "off on"
    @element.addClass "load"

  start : () ->
    @setInPgrogress()
    @eventBus.emit "daemon-control:run", {daemonItem:@daemonItem,start:true}
  stop : () ->
    @setInPgrogress()
    @eventBus.emit "daemon-control:run", {daemonItem:@daemonItem,start:false}
  toggle: ->
    if not @isInProgress
      if @status
        @stop()
      else @start()
    else atom.notifications.addInfo "Wait"

  hide: -> #TODO: Change?
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'
