DaemonItem = require './daemon-item.coffee'
{File} = require 'atom'
CheckListView = require './views/check-list-view'
{ModalFileManagerView} = require 'modal-file-manager'

module.exports =
class DaemonAddWizard
  constructor: (@daemonManagement) ->
    #@run()
  run: ->
    #new CheckListView()
    mfm = new ModalFileManagerView
    mfm.open atom.project.getPaths()[0], (file) =>
        console.log "path: #{file.getBaseName()}"
    #atom.pickFolder (path) =>
    #@pickFile (filePath) ->
    #  console.log filePath
    #  @saveDaemon filePath

  saveDaemon: (filePath) ->
    file = new File filePath
    @daemonManagement.addDaemon new DaemonItem #MacOS, Linux
      name: file.getParent().getBaseName()
      cmdRun: file.path
      cmdStop: "killall #{file.path}"
      cmdCheck: "ps -ax"
      strCheck: file.path

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
