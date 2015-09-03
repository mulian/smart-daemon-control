{BufferedProcess} = require 'atom'

module.exports =
class DaemonControll
  constructor: () ->

  #check if Service is already startet and run CallBack (cb) function
  launchctl_check:(service_file_name,cbIsRunning,cbIsNotRunning) ->
    command = "launchctl"
    args = ["list"]
    stdout = (output) ->
      #console.log(output)
      if output.indexOf(service_file_name) >- 1
        cbIsRunning()
      else
        cbIsNotRunning()
    exit = (code) ->
      console.log("#{command} exited with #{code}")
    process = new BufferedProcess({command, args, stdout, exit})

  #run launchctl to (un)load service's
  launchctl_run:(service_path,start=true,cb) ->
    load = if start then 'load' else 'unload'

    command = "launchctl"
    args = [load,service_path]
    stdout = (output) ->
      #if output.indexOf(str) > -1
    exit = (code) =>
      console.log("#{load} #{service_path}")
      cb(false)
    process = new BufferedProcess({command, args, stdout, exit})
