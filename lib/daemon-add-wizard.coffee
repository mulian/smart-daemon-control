DaemonItem = require './daemon-item.coffee'
{File,Emitter} = require 'atom'
CheckListView = require './views/check-list-view'
{ModalFileManagerView} = require 'modal-file-manager'

module.exports =
class DaemonAddWizard
  constructor: (@eventBus,@daemonManagement) ->
    #@run()
    option = {} =
      'darwin':
        filterDir: /.app$/
        filterFile: true
      'win32':
        filterDir: false
        filterFile: /.exe$/
      'linux':
        filterDir: false
        filterFile: true
    @mfm = new ModalFileManagerView option[process.platform]

  getRootPathFromOs: ->
    return "C:/" if process.platform=='win32'
    return "/" #else
    #atom.project.getPaths()[0] #project path

  run: ->
    @mfm.open @getRootPathFromOs(), (file) =>
        @saveDaemon file

  saveDaemon: (file) ->
    item = {}
    cmdStop=""
    if file.getBaseName().indexOf(".app")>0
      cmdStop= "killall #{file.getBaseName().slice(0,file.getBaseName().length-4)}"
    else cmdStop= "killall #{file.getBaseName()}"
    switch process.platform #linux users know how to add Deamons ;)
      when "darwin" then item = new DaemonItem #MacOS, Linux
        name: file.getParent().getBaseName()
        cmdRun: "open #{file.path}"
        cmdStop: cmdStop
        cmdCheck: "ps -ax"
        strCheck: file.path
      when "win32" then item = new DaemonItem #Windows
        name: file.getParent().getBaseName()
        cmdRun: file.path
        cmdStop: "taskkill #{file.path}"
        cmdCheck: "tasklist"
        strCheck: file.getBaseName()
    @eventBus.emit "daemon-management-add-daemon", item
    @eventBus.emit "daemon-item-configure-view-show", item
    # @daemonManagement.addDaemon item
    # @daemonManagement.showItemConfig item



  # pickFile: (callback) ->
  #   prePaneURI = atom.workspace.getActivePaneItem().getURI()
  #   preTabLength = atom.workspace.getPaneItems().length
  #   preProjectLength = atom.project.getDirectories().length
  #   #Do not open a Directory
  #   disposeItem = atom.workspace.onDidOpen (event) -> #on select file
  #     atom.notifications.addError event.uri
  #     #console.log event.uri
  #     if atom.project.getDirectories().length==preProjectLength
  #       callback event.uri
  #     #close tab, if tab is new
  #     if atom.workspace.getPaneItems().length>preTabLength
  #       event.item.destroy()
  #     else #open pre. tab
  #       atom.workspace.open prePaneURI
  #     disposeItem.dispose() #to run only once after atom.open
  #
  #   atom.open()
