packageName = require('../package.json').name
{$} = require 'atom-space-pen-views'

module.exports =
class DaemonStatusBarItemView
  element : null
  status : null
  inProcess : false
  dblclickTimeout : null

  constructor : (@eventBus,@daemonItem) ->
    @eventBus.on "daemon-status-bar-item-view-set-on", (daemonItem) =>
      if daemonItem.id==@daemonItem.id
        @setRunning()
    @eventBus.on "daemon-status-bar-item-view-set-off", (daemonItem) =>
      if daemonItem.id==@daemonItem.id
        @setStop()
    @element = $("<span/>",
      class : 'smart-daemon-control-item load'
      text : @daemonItem.name
    )
    @status = false
    @element.click (event) =>
      if @dblclickTimeout == null
        @dblclickTimeout = setTimeout =>
          @toggle()
          @dblclickTimeout = null
        , 200
      else
        clearTimeout @dblclickTimeout
        @dblclickTimeout=null
        @showConfig()
    @checkStatus()
    @addSettingListener()
    @checkHide()

  refresh: () ->
    @checkHide()
    @element.text @daemonItem.name

  showConfig: () ->
    @eventBus.emit "daemon-item-configure-view-show", @daemonItem

  checkHide : () ->
    if @daemonItem.hide
      @hide()
    else @show()

  addSettingListener : () ->
    #on set invisble

  checkStatus : () ->
    console.log "check?"
    @eventBus.emit "daemon-control-check", @daemonItem
    #@daemonManagement.daemonControl.check @daemonItem, @setRunning, @setStop

  setRunning : () =>
    @element.removeClass "off load"
    @element.addClass "on"
    @status=true
  setStop : () =>
    @element.removeClass "on load"
    @element.addClass "off"
    @status=false
    if @daemonItem.autorun
      @start()
      @daemonItem.autorun=false

  setLoad : () =>
    @inProcess=true
    @element.removeClass "off on"
    @element.addClass "load"

  toggle: () ->
    if @status
      @stop()
    else @start()

  startCallBack : (err) =>
    @inProcess=false
    if err
      atom.notifications.addError "Fehler startCallBack"
    else
      @setRunning()
  start : () ->
    if !@inProcess
      @setLoad()
      @eventBus.emit "daemon-control-run", @daemonItem,true, @startCallBack
      #@daemonManagement.daemonControl.run @daemonItem,true, @startCallBack
    else atom.notifications.addInfo "Wait"

  stopCallBack : (err) =>
    @inProcess=false
    if err
      atom.notifications.addError "Fehler startCallBack"
    else
      @setStop()
  stop : () ->
    if !@inProcess
      @setLoad()
      @eventBus.emit "daemon-control-run", @daemonItem,false, @stopCallBack
      #@daemonManagement.daemonControl.run @daemonItem,false, @stopCallBack
    else atom.notifications.addInfo "Wait"

  hide: -> #TODO: Change?
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'
