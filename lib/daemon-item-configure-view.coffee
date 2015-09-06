$ = require 'jquery'
{TextEditorView,View} = require 'atom-space-pen-views'
DaemonItem = require './daemon-item'

module.exports =
class DaemonItemConfigureView extends View
  @content: ->
    @table id: 'daemon-item-manager', =>
      @tr =>
        @td =>
          @div "Edit Daemon", id: "daemon-item-title", click: 'kill'
        @td =>
          @button "Delete Daemon", click: 'delete'
#        @td =>
#          @select id:"select-daemon", =>
#            @option "mysql"
#            @option "nginx"
#            @option "php56"
      @tr class: "daemon-name", =>
        @td =>
          @div "Daemon Name"
        @td =>
          @input type:"text", id: "daemon-item-name", autofocus: true
      @tr class: "daemon-cmd-run", =>
        @td =>
          @div "run command"
        @td =>
          @input type:"text", id: "daemon-item-cmd-run"
      @tr class: "daemon-cmd-stop", =>
        @td =>
          @div "stop command"
        @td =>
          @input type:"text", id: "daemon-item-cmd-stop"
      @tr =>
        @td class: "daemon-cmd-check", =>
          @div "check command"
        @td =>
          @input type:"text", id: "daemon-item-cmd-check"
      @tr =>
        @td title:"true if isin check cmd result", "check string" , =>
        @td =>
          @input type:"text", id: "daemon-item-str-check"
      @tr class: "daemon-hide", =>
        @td =>
          @div "hide"
        @td =>
          @input type:"checkbox", id: "daemon-item-hide"
      @tr class: "daemon-autorun", =>
        @td =>
          @div "start with atom"
        @td =>
          @input type:"checkbox", id: "daemon-item-autorun"
      @tr class: "daemon-autorun-project", =>
        @td =>
          @div "start with this project"
        @td =>
          @input type:"checkbox", id: "daemon-item-project-autorun"


  initialize: ->
    $('#daemon-item-title').mousedown @test

  attach: (@smartDaemonControl) ->
    @modalPanel = atom.workspace.addModalPanel(item: @, visible: false)
    @initialize();

  delete: () =>
    @smartDaemonControl.removeDaemon @daemonItem
    @modalPanel.hide()

  load: (@daemonItem) ->
    $('#daemon-item-name').attr('value', @daemonItem.name).keyup (event) =>
      @daemonItem.name = event.target.value
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-cmd-run').attr('value',@daemonItem.cmdRun).keyup (event) =>
      @daemonItem.cmdRun = event.target.value
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-cmd-stop').attr('value',@daemonItem.cmdStop).keyup (event) =>
      @daemonItem.cmdStop = event.target.value
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-cmd-check').attr('value',@daemonItem.cmdCheck).keyup (event) =>
      @daemonItem.cmdCheck = event.target.value
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-str-check').attr('value',@daemonItem.strCheck).keyup (event) =>
      @daemonItem.strCheck = event.target.value
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-hide').prop('checked',@daemonItem.hide).change (event) =>
      @daemonItem.hide = $(event.target).prop('checked')
      @smartDaemonControl.refreshDaemonItem(daemonItem)
    $('#daemon-item-autorun').prop('checked',@daemonItem.autorun).change (event) =>
      @daemonItem.autorun = $(event.target).prop('checked')
      @smartDaemonControl.refreshDaemonItem(daemonItem)

  aus: ->
    console.log "BLUBB:"
    console.log this.element
  test: ->
    console.log "DOWN"
  kill: ->
    console.log "kill"
