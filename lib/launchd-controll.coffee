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

  hideAll: () ->
    #TODO

  aktivateAll: () ->
    #TODO

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @compositeDisposable = new CompositeDisposable

    @launchdControllView = new LaunchdControllView(state.launchdControllViewState)

    str = "launchd-controll:blubb"
    # Register command that toggles this view
    @compositeDisposable.add atom.commands.add 'atom-workspace',
        'launchd-controll:install' : ()=> @install()
        'launchd-controll:hideall' : ()=> @hideAll()
        'launchd-controll:aktivateall' : ()=> @aktivateAll()

  consumeStatusBar: (statusBar) ->
    @launchdControllView.initialize statusBar
    @launchdControllView.attach()


  test:() ->
    div = document.createElement('div')

    atom.workspace.addBottomPanel(item: div,visible: true)


  deactivate: ->
    #@modalPanel.destroy()
    @compositeDisposable.dispose()
    @launchdControllView.detach()

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
      atom.notifications.addWarning "Nothing found to add."
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
