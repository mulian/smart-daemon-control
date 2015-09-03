$ = jQuery = require 'jquery'

module.exports =
class DaemonIconView
  element : null
  status : null
  inProcess : false

  constructor : (@serializedState,@name,@path,@daemonControll) ->
    @element = $("<span/>",
      class : 'launchd-controll-daemon-icon load'
      text : @name
    )
    @status = false
    @element.click (event) =>
      @toggle()
    @checkStatus()

  checkStatus : () ->
    @daemonControll.launchctl_check @name, @setRunning, @setStop

  setRunning : () =>
    @element.removeClass "off load"
    @element.addClass "on"
    @status=true
  setStop : () =>
    @element.removeClass "on load"
    @element.addClass "off"
    @status=false

  setLoad : () =>
    @inProcess=true
    @element.removeClass "off on"
    @element.addClass "load"

  toggle: () ->
    if @status @stop()
    else @start()

  startCallBack : (err) =>
    @inProcess=false
    if err
      console.log "Fehler startCallBack"
    else
      @setRunning()
  start : () ->
    if !@inProcess
      @setLoad()
      @daemonControll.launchctl_run @path, true, @startCallBack
    else console.log "There is already an process"

  stopCallBack : (err) =>
    @inProcess=false
    if err
      console.log "Fehler startCallBack"
    else
      @setStop()
  stop : () ->
    if !@inProcess
      @setLoad()
      @daemonControll.launchctl_run @path, false, @stopCallBack
    else console.log "There is already an process"
