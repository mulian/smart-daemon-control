{TextEditorView,View,$} = require 'atom-space-pen-views'

#TODO: less jquery more atom-space-pen
module.exports =
class DaemonItemConfigureView extends View
  @content: ->
    @table id: 'daemon-item-manager' , =>
      @tr =>
        @td =>
          @div "Edit Daemon", id: "daemon-item-title"#, click: 'kill'
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
          @subview 'daemon-item-name', new TextEditorView(mini: true), autofocus: true
#          @input type:"text", id: "daemon-item-name", autofocus: true
      @tr class: "daemon-cmd-run", =>
        @td =>
          @div "run command"
        @td =>
          @subview 'daemon-item-cmd-run', new TextEditorView(mini: true)
          #@input type:"text", id: "daemon-item-cmd-run"
      @tr class: "daemon-cmd-stop", =>
        @td =>
          @div "stop command"
        @td =>
          @subview "daemon-item-cmd-stop", new TextEditorView(mini: true)
          #@input type:"text", id: "daemon-item-cmd-stop"
      @tr =>
        @td class: "daemon-cmd-check", =>
          @div "check command"
        @td =>
          @subview "daemon-item-cmd-check", new TextEditorView(mini: true)
          #@input type:"text", id: "daemon-item-cmd-check"
      @tr =>
        @td title:"true if isin check cmd result", "check string" , =>
        @td =>
          @subview "daemon-item-str-check", new TextEditorView(mini: true)
          #@input type:"text", id: "daemon-item-str-check"
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

  showTime : false

  constructor: (@eventBus) ->
    super
    @eventBus.on "daemon-item-configure-view:show", (item) =>
      @load item
      @show()

  initialize: ->
    @autoHide()
    @attach()

  attach: ->
    @panel = atom.workspace.addModalPanel(item: @, visible: false)

  delete: =>
    onYes = =>
      @eventBus.emit 'daemon-item-collection:remove', @daemonItem
      @panel.hide()
    @ask onYes
  ask: (yesCallback,noCallback) ->
    atom.confirm
      message: "Do you realy want to delete #{@daemonItem.name}?"
      buttons:
        yes: -> yesCallback() if yesCallback?
        no: -> noCallback() if noCallback?

  autoHide: () ->
    $('body').click (event) =>
      @hide() if !$(event.target).closest('#daemon-item-manager').length

  show: () ->
    @panel.show()
    #this prevent the hide after dblclick on daemon-item
    @showTime = true
    setTimeout =>
      @showTime = false
    , 200
  hide: ->
    @panel.hide() if not @showTime

  bindTextEditorView: (editorKey,daemonItemKey) ->
    #@[editorKey].model.off 'did-change'
    @[editorKey].model.setText @daemonItem[daemonItemKey] if @daemonItem[daemonItemKey]?
    @[editorKey].model.emitter.on 'did-change', =>
      @daemonItem[daemonItemKey] = @[editorKey].model.getText()
      @eventBus.emit 'daemon-item-collection:change', @daemonItem

  load: (@daemonItem) ->
    @bindTextEditorView 'daemon-item-name',      'name'
    @bindTextEditorView 'daemon-item-cmd-run',   'cmdRun'
    @bindTextEditorView 'daemon-item-cmd-stop',  'cmdStop'
    @bindTextEditorView 'daemon-item-cmd-check', 'cmdCheck'
    @bindTextEditorView 'daemon-item-str-check', 'strCheck'

    $('#daemon-item-hide').prop('checked',@daemonItem.hide).change (event) =>
      @daemonItem.hide = $(event.target).prop('checked')
      @eventBus.emit 'daemon-item-collection:change', daemonItem
    $('#daemon-item-autorun').prop('checked',@daemonItem.autorun).change (event) =>
      @daemonItem.autorun = $(event.target).prop('checked')
      @eventBus.emit 'daemon-item-collection:change', daemonItem

    # $('#daemon-item-cmd-run').attr('value',@daemonItem.cmdRun).keyup (event) =>
    #   @daemonItem.cmdRun = event.target.value
    #   @daemonManagement.refreshDaemonItem(daemonItem)
