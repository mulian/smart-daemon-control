packageName = require('../package.json').name
$ = require 'jquery'

module.exports =
class DaemonControlItemView
  element : null
  status : null
  inProcess : false

  constructor : (@serializedState,@setting,@daemonControl) ->
    @element = $("<span/>",
      class : 'smart-daemon-control-item load'
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
    atom.config.onDidChange "#{packageName}.#{@setting.key}", ({newValue, oldValue}) =>
      @setSettings newValue

  checkStatus : () ->
    @daemonControl.launchctl_check @setting.key, @setRunning, @setStop

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
      @daemonControl.launchctl_run @setting.path, true, @startCallBack
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
      @daemonControl.launchctl_run @setting.path, false, @stopCallBack
    else atom.notifications.addInfo "Wait"

  hide: ->
    @element.addClass 'hidden'
  show: ->
    @element.removeClass 'hidden'
