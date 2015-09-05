$ = require 'jquery'
{View} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'

module.exports =
class DaemonItemView extends View
  @content: ->
    @table class: 'test', =>
      @tr =>
        @td colspan:'2', =>
          @div "Titel", id: "daemon-item-title", click: 'kill'
      @tr class: "daemon-name", =>
        @td =>
          @div "Daemon Name:"
        @td =>
          @input type:"text", id: "daemon-item-answer"
      @tr class: "daemon-cmd-run", =>
        @td =>
          @div "run command:"
        @td =>
          @input type:"text", id: "daemon-item-answer"
      @tr class: "daemon-cmd-stop", =>
        @td =>
          @div "stop command:"
        @td =>
          @input type:"text", id: "daemon-item-answer"
      @tr =>
        @td class: "daemon-cmd-check", =>
          @div "check command:"
        @td =>
          @span =>
            @input type:"text", id: "daemon-check-cmd"
          @span =>
            @input type:"text", id: "daemon-check-str"
      @tr class: "daemon-hide", =>
        @td =>
          @div "hide:"
        @td =>
          @input type:"text", id: "daemon-item-answer"
      @tr class: "daemon-autorun", =>
        @td =>
          @div "auto run at atom startup:"
        @td =>
          @input type:"text", id: "daemon-item-answer"
      @tr class: "daemon-autorun-project", =>
        @td =>
          @div "auto run at this project startup:"
        @td =>
          @input type:"text", id: "daemon-item-answer"

#@subview 'answer', new TextEditorView(mini: true)
  initialize: ->
    $('#daemon-item-title').mousedown @test

  attach: ->
    @modalPanel = atom.workspace.addModalPanel(item: @, visible: false)
    @initialize();
  aus: ->
    console.log "BLUBB:"
    console.log this.element
  test: ->
    console.log "DOWN"
  kill: ->
    console.log "kill"
