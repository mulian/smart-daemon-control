{BufferedProcess} = require 'atom'

module.exports =
class DaemonControl
  constructor: ->
    @eb = eb.smartDaemonControl
    @eb.ebAdd 'daemonControl', {} =
      checkAll: @letsCheckAll
      run: @run
    # @eventBus.on "daemon-control:checkAll", @letsCheckAll
    # @eventBus.on "daemon-control:run", @run

  strToCmd: (str) ->
    res = str.split " "
    return {} =
      command: res.shift(),
      args: res

  #to sumerize all checks if they came in short time
  letsCheckAll: (checks) =>
    clearTimeout @_timeOut if @_timeOut?
    @_timeOut = setTimeout =>
      @checkAll checks
      delete @_timeOut
    , 200
  _firstTime: true
  checkAll: (checks) ->
    for checkStr,checkList of checks
      copyList = checkList.slice(0)
      @check checkStr,copyList
  check: (checkStr,checkList) ->
    {command,args} = @strToCmd checkStr
    stdout = (output) =>
      #need a decrement loop, because of remove (splice x,1)
      key = checkList.length
      while key--
        item = checkList[key]
        if (output.indexOf(item.strCheck) > -1)
          console.log "on", item.name
          @eb.statusBarItemView.aktivate item
          # @eventBus.emit 'status-bar-item-view:aktivate', item
          checkList.splice key,1
    exit = (code) =>
      for item in checkList
        console.log "off", item.name
        @eb.statusBarItemView.deaktivate item
        # @eventBus.emit 'status-bar-item-view:deaktivate', item
        #if it is deactivated and autorun, run it!
        if item.autorun and @_firstTime
          @eb.daemonControl.run {daemonItem:item,start:true}
          # @eventBus.emit 'daemon-control:run', {daemonItem:item,start:true}
      @_firstTime=false
    process = new BufferedProcess {command,args,stdout,exit}
    process.onWillThrowError (err) ->
      console.log err
      atom.notifications.addError "smart-daemon-control: #{err.error.path} is not a valid check command!"
      err.handle()


  run: ({daemonItem,start}) =>
    if start
      cmdStr = daemonItem.cmdRun
    else
      cmdStr = daemonItem.cmdStop
    if cmdStr?
      {command,args} = @strToCmd cmdStr
      exit = (code) =>
        @check daemonItem.cmdCheck, [daemonItem]
      process = new BufferedProcess({command, args, exit})
      process.onWillThrowError (err) ->
        console.log err
        atom.notifications.addError "smart-daemon-control: #{err.error.path} is not a valid start/stop command!"
        err.handle()
    else
      atom.notifications.addInfo "daemon-run/-stop values not set"
