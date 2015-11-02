{BufferedProcess} = require 'atom'

module.exports =
class DaemonControl
  constructor: (@eventBus) ->
    @eventBus.on "daemon-control:checkAll", @letsCheckAll
    @eventBus.on "daemon-control:run", @run

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
          @eventBus.emit 'status-bar-item-view:aktivate', item
          checkList.splice key,1
    exit = (code) => #remove?
      for item in checkList
        @eventBus.emit 'status-bar-item-view:deaktivate', item
    process = new BufferedProcess {command,args,stdout,exit}

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
    else
      atom.notifications.addInfo "daemon-run/-stop values not set"
