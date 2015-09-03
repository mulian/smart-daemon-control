LaunchdControllView = require './launchd-controll-view'
{CompositeDisposable,Directory,File} = require 'atom'
configFileName = '../config.json'

installTimeOut = null

clone = (obj) ->
  return obj if null == obj || "object" != typeof obj
  copy = obj.constructor();
  for key,value in obj
    copy[key] = value if obj.hasOwnProperty key
  copy

module.exports = LaunchdControll =
  config: require configFileName
  defaultConfig: {}

  launchdControllView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    console.log "state"
    console.log @
    @launchdControllView = new LaunchdControllView(state.launchdControllViewState)
    #@modalPanel = document.querySelector("status-bar").addLeftTile(item: @launchdControllView.getElement(), priority: 100)
    #@modalPanel = atom.workspace.addBottomPanel(
    # @modalPanel = atom.workspace.addBottomPanel(
    #   item: @launchdControllView.getElement(),
    #   visible: false
    # )

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'launchd-controll:install': => @install()

    #meins
    # filterElement = document.createElement 'atom-text-editor'
    # filterElement.setAttribute 'mini', true
    # filterElement.classList.add 'inline-block'
    # filterElement.classList.add 'birch-statusbar-filter'
    # filterStatusBarItem = statusBar.addLeftTile(item: filterElement, priority: 0)

  consumeStatusBar: (statusBar) ->
    @statusBarTile = statusBar.addLeftTile(
      item: @launchdControllView.getElement(),
      priority: 100
    )

  test:() ->
    div = document.createElement('div')

    atom.workspace.addBottomPanel(item: div,visible: true)


  deactivate: ->
    #@modalPanel.destroy()
    #@subscriptions.dispose()
    #@launchdControllView.destroy()

  serialize: ->
    launchdControllViewState: @launchdControllView.serialize()

  autoSearch: ->
    if process.platform == "darwin" #mac
      console.log process.platform
      dir = new Directory('/usr/local/opt/')
      if dir.isDirectory() #brew
        @searchBrewPlist dir

    else if process.platform == "win32" #win
      console.log process.platform

  searchBrewPlist: (dir) ->
    re = /\.plist$/
    searchPlist = (dir) =>
      dir.getEntries (err,entries) =>
        for entrie in entries
          if entrie.isDirectory()
            searchPlist entrie
          else
            if re.exec(entrie.getBaseName()) != null
              regNewPlist entrie
    regNewPlist = (file) =>
      #console.log "Servicename: #{file.getParent().getBaseName()}, filename: #{file.path}"
      @addEntrieToConfig file.getParent().getBaseName(), file.path
    #console.log "scan dir for *.plist"
    searchPlist dir

  install: ->
    #console.log 'Install LaunchdControll!'
    @config = clone @defaultConfig
    @autoSearch()
  isInstalled: ->
    Object.keys(@defaultConfig).length < Object.keys(@config).length

  toggle: ->
    #onsole.log "modalPanel is Visible? #{@modalPanel.visible}"
    #console.log @modalPanel
    #console.log "Atom Workspace:"
    #console.log atom.workspace

    #if @modalPanel.isVisible()
    #  @modalPanel.hide()
    #else
    #  @modalPanel.show()

  addEntrieToConfig: (serviceName,fileName) ->
    @config[serviceName] =
      type: 'object'
      properties:
        "path":
          type: 'string'
          default: fileName
        "hide":
          type: 'boolean'
          default: false
        "Start with Atom":
          type: 'boolean'
          default: false
    @saveToConfig()

  postInstall : ->
    if @isInstalled()
      atom.notifications.addInfo "Restart Atom, and look at lauchd-controll settings"
      console.log "Succes"
    else
      #nothing added!
      console.log "error"

  saveToConfig: ->
    #console.log @config
    __rootPackageDir = atom.packages.loadedPackages["launchd-controll"].path
    file = new File("#{__rootPackageDir}/config.json")
    file.write JSON.stringify(@config,null,4)
    clearTimeout installTimeOut
    installTimeOut = setTimeout =>
      @postInstall()
    , 100
