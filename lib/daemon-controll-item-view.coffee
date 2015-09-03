$ = require 'jquery'

module.exports =
class DaemonControllItemView
  element : null
  status : null
  inProcess : false

  constructor : (@serializedState,@setting,@daemonControll) ->
    @element = $("<span/>",
      class : 'launchd-controll-daemon-icon load'
      text : @setting.key
    )
    @status = false
    @element.click (event) =>
      @toggle()
    @checkStatus()
    @addSettingListener()
    @setSettings(@setting)

  setSettings : (@setting) ->
    if @setting.hide
      @hide()
    else @show()

  addSettingListener : () ->
    atom.config.onDidChange "launchd-controll.#{@setting.key}", ({newValue, oldValue}) =>
      @setSettings newValue

  checkStatus : () ->
    @daemonControll.launchctl_check @setting.key, @setRunning, @setStop

  setRunning : () =>
    @element.removeClass "off load"
    @element.addClass "on"
    @status=true
  setStop : () =>
    @element.removeClass "on load"
    @element.addClass "off"
    @status=false
    if @setting.autostart
      @start()
      @setting.autostart=false

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
      @daemonControll.launchctl_run @setting.path, true, @startCallBack
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
      @daemonControll.launchctl_run @setting.path, false, @stopCallBack
    else atom.notifications.addInfo "Wait"

  hide: ->
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'
