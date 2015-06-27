LaunchdControllView = require './launchd-controll-view'
{CompositeDisposable} = require 'atom'

module.exports = LaunchdControll =
  launchdControllView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @launchdControllView = new LaunchdControllView(state.launchdControllViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @launchdControllView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'launchd-controll:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @launchdControllView.destroy()

  serialize: ->
    launchdControllViewState: @launchdControllView.serialize()

  toggle: ->
    console.log 'LaunchdControll was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
