packageName = require('../package.json').name
$ = require 'jquery'

module.exports =
class DaemonStatusBarContainerView
  element : null
  status : null
  inProcess : false
  dblclickTimeout : null

  constructor : (@serializedState,@daemonItem,@daemonManagement) ->
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
    @daemonManagement.showItemConfig @daemonItem

  checkHide : () ->
    if @daemonItem.hide
      @hide()
    else @show()

  addSettingListener : () ->
    #on set invisble

  checkStatus : () ->
    @daemonManagement.daemonControl.check @daemonItem, @setRunning, @setStop

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
      @daemonManagement.daemonControl.run @daemonItem.cmdRun, @startCallBack
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
      @daemonManagement.daemonControl.run @daemonItem.cmdStop, @stopCallBack
    else atom.notifications.addInfo "Wait"

  hide: ->
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'
