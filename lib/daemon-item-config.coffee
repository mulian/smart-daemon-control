DaemonItem = require './daemon-item.coffee'
{File} = require 'atom'
CheckListView = require './views/check-list-view'
{ModalFileManagerView} = require 'modal-file-manager'

#Löschen?

module.exports =
class DaemonItemConfig
  constructor: (@daemonItem) ->
    @mfm = new ModalFileManagerView
      filterDir: /.app$/ if process.platform=='darwin'
      filterFile: /.exe$/ if process.platform=='win32'

  getRootPathFromOs: ->
    return "C:/" if process.platform=='win32'
    return "/" #else
    #atom.project.getPaths()[0] #project path

  setPath: (itemParameterName,path)->
    if path?
      @daemonItem[itemParameterName]=path
    else #path==undefined
      @mfm.open @getRootPathFromOs(), (file)=>
        @setPath itemParameterName,file.getRealPathSync()
