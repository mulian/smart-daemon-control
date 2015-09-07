{BufferedProcess} = require 'atom'

module.exports =
class DaemonControl
  constructor: () ->

  strToCmd: (str) ->
    res = str.split " "
    return {} =
      command: res.shift(),
      args: res

  check: (daemonItem,cbIsRunning,cbIsNotRunning) ->
    if daemonItem.cmdCheck?
      cmd = @strToCmd daemonItem.cmdCheck
      command = cmd.command
      args = cmd.args
      alreadyGetCheckString = false
      stdout = (output) ->
        if output.indexOf(daemonItem.strCheck) >- 1
          alreadyGetCheckString = true
      exit = (code) ->
        if alreadyGetCheckString
          cbIsRunning()
        else cbIsNotRunning()
      process = new BufferedProcess({command, args, stdout, exit})
    else
      atom.notifications.addInfo "Daemon #{daemonItem.name}: daemon-cmdCheck values not set"

  run: (cmdStr,cb) ->
    if cmdStr?
      cmd = @strToCmd cmdStr
      command = cmd.command
      args = cmd.args
      stdout = (output) ->
        #if output.indexOf(str) > -1
      exit = (code) =>
        cb()
      process = new BufferedProcess({command, args, stdout, exit})
    else
      atom.notifications.addInfo "daemon-run/-stop values not set"
      cb(-1)
