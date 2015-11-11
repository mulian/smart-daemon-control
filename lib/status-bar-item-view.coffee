packageName = require('../package.json').name
# {$} = require 'atom-space-pen-views'
{View,$} = require 'atom-space-pen-views'

module.exports =
class StatusBarItemView #TODO: add class View
  constructor : (@daemonItem) ->
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
    @eb = eb.smartDaemonControl
    # eb.debug=true
    @eb.eb 'statusBarItemView', {} =
      thisArg : @
      "remove": (item) => @_amI item,@removeMe
      "hide": (item) => @_amI item,@hide
      "show": (item) => @_amI item,@show
      "refresh": (item) => @_amI item,@refresh
      "aktivate": (item) => @_amI item,@setRunning
      "deaktivate": (item) => @_amI item,@setNotRunning
    # eb.debug=false
    # @eventBus.on "status-bar-item-view:remove", (item) => @remove() if @_amI item #delete?
    # @eventBus.on "status-bar-item-view:hide", (item) => @hide() if @_amI item
    # @eventBus.on "status-bar-item-view:show", (item) => @show() if @_amI item
    # @eventBus.on "status-bar-item-view:refresh", (item) => @refresh item if @_amI item
    #
    # @eventBus.on "status-bar-item-view:aktivate", (item) => @setRunning() if @_amI item
    # @eventBus.on "status-bar-item-view:deaktivate", (item) => @setNotRunning() if @_amI item

  refresh: (item) =>
    @daemonItem = item
    @element.text @daemonItem.name
    @checkHide()

  _amI: (item,call) ->
    call item if item.id==@daemonItem.id
    # console.log "_amI",item.name,"!=",@daemonItem.name
    return false

  removeMe: =>
    $(@element).remove()

  showConfig: () ->
    @eb.daemonItemConfigureView.show @daemonItem
    # @eventBus.emit "daemon-item-configure-view:show", @daemonItem

  checkHide : () ->
    if @daemonItem.hide
      @hide()
    else @show()

  setRunning : () =>
    # console.log "set on",@daemonItem.name
    @element.removeClass "off load"
    @element.addClass "on"
    @status=true
    @isInProgress=false
  setNotRunning : () =>
    @element.removeClass "on load"
    @element.addClass "off"
    @status=false
    @isInProgress=false
  setInPgrogress : () =>
    @isInProgress=true
    @element.removeClass "off on"
    @element.addClass "load"

  start : () ->
    @setInPgrogress()
    @eb.daemonControl.run {daemonItem:@daemonItem,start:true}
    # @eventBus.emit "daemon-control:run", {daemonItem:@daemonItem,start:true}
  stop : () ->
    @setInPgrogress()
    @eb.daemonControl.run {daemonItem:@daemonItem,start:false}
    # @eventBus.emit "daemon-control:run", {daemonItem:@daemonItem,start:false}
  toggle: ->
    if not @isInProgress
      if @status
        @stop()
      else @start()
    else atom.notifications.addInfo "Wait"

  hide: -> #TODO: Change?
    @element?.addClass 'hidden'
  show: ->
    @element?.removeClass 'hidden'
