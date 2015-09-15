module.exports =
class DaemonItem
  constructor: (options) ->
    {@name, @cmdRun, @cmdStop, @cmdCheck, @strCheck, @hide, @autorun} = options
    #@hide,@autorun=false dont works, workaround:
    @hide=false if @hide?
    @autorun=false if @autorun?
