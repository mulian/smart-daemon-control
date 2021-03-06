DaemonItem = require "./daemon-item"
#atom.project.rootDirectories[0].path

module.exports =
class DaemonItemCollection
  atom.deserializers.add(this)

  # @version: 0.1
  @deserialize: ({data}) ->
    return new DaemonItemCollection data
  serialize: ->
    return {} =
      deserializer: 'DaemonItemCollection'
      data:
        items: @items
        checks: @checks
      # version: @constructor.version

  constructor: (data) ->
    @reqEventBus()
    # data=undefined #reset list
    # console.log @items
    # console.log @checks
    if data?
      {@items,@checks}=data
      for key,item of @items
        if key!='inc'
          @addCommands item
          # @eventBus.emit 'daemon-control:run', {daemonItem:item,start:true} if item.autorun
    else
      @items = {} =
        inc: 0
      @checks = {}
    # console.log @checks

  reqEventBus: ->
    @eb = eb.smartDaemonControl
    # eb('on',{thisArg:@}) 'SmartDaemonControl.DaemonItemCollection', {} =
    @eb.eb 'daemonItemCollection', {} =
      thisArg:@
      add : (item) => @_callWhenDaemonItem item,@add
      remove : (item) => @_callWhenDaemonItem item,@remove
      change : (item) => @_callWhenDaemonItem item,@change
      new : (item) => @_callWhenDaemonItem item,@new
      get : @get
      checkStates : @checkStates
    # @eventBus.on 'daemon-item-collection:add', (item) => @_callWhenDaemonItem item,@add
    # @eventBus.on 'daemon-item-collection:remove', (item) => @_callWhenDaemonItem item,@remove
    # @eventBus.on 'daemon-item-collection:change', (item) => @_callWhenDaemonItem item,@change
    # @eventBus.on 'daemon-item-collection:get', @get
    # @eventBus.on 'daemon-item-collection:new', (item) => @_callWhenDaemonItem item,@new
    # @eventBus.on 'daemon-item-collection:checkStates', @checkStates

  checkStates: =>
    # checks = @checks.slice(0) #copy
    @eb.daemonControl.checkAll @checks
    # @eventBus.emit 'daemon-control:checkAll', @checks

  #There are 2 Kinds of item:
  # * DaemonItem Object
  # * Or an Array with DaemonItem
  # call== callback
  _callWhenDaemonItem: (item,call) ->
    if (item instanceof DaemonItem) or (item instanceof Object)
      call item
    else if item instanceof Array
      for i in item
        call i
    else
      console.log "ERROR on _callWhenDaemonItem"

  change: (item) =>
    # console.log "change"
    #TODO: status-bar checks: daemon-item-collection:change not like this
    #will be automatic changed, this is only a trigger
    @changeCheck item
    @eb.statusBarItemView.refresh item
    # @eventBus.emit 'status-bar-item-view:refresh', @items[item.id]

  changeCheck: (item) -> #TODO: reuse add and remove functions?
    if item.checkAdded != item.cmdCheck
      #remove from checkAdded list
      if @checks[item.checkAdded]?
        if @checks[item.checkAdded].length==1
          delete @checks[item.checkAdded]
        else
          console.log item.checkAdded, @checks
          for i,key in @checks[item.checkAdded]
            if i.id==item.id
              @checks[item.checkAdded].splice key,1
      #add on new list
      if item.cmdCheck? and item.cmdCheck.length>0
        @checks[item.cmdCheck] = [] if not @checks[item.cmdCheck]?
        @checks[item.cmdCheck].push item
        item.checkAdded = item.cmdCheck

    #update check item
    if @checks[item.cmdCheck]?
      # console.log "check:"
      for i,key in @checks[item.cmdCheck]
        if i.id==item.id
          # console.log "found"
          @checks[item.cmdCheck].splice key,1
          break;
      @checks[item.cmdCheck].push item


  new: =>
    newItem = new DaemonItem {name: "New"}
    @add newItem
    @eb.daemonItemConfigureView.show newItem
    # @eventBus.emit 'daemon-item-configure-view:show', newItem

  #If there is an id, return only item with id
  #else return collection
  get: (cb) =>
    for key,item of @items
      if key!='inc'
        cb item

  add: (item) =>
    item.id = @items.inc
    @items[item.id] = item
    @items.inc++
    @addCommands item
    @eb.statusBarContainerView.add item
    # @eventBus.emit 'status-bar-container-view:add', item
    @addCheck item
    return true
  addCheck: (item) ->
    if item.cmdCheck? and item.cmdCheck.length>0
      @checks[item.cmdCheck]=[] if not @checks[item.cmdCheck]?
      @checks[item.cmdCheck].push item
      #for change
      item.checkAdded = item.cmdCheck

  remove: (item) =>
    # console.log item
    #if daemonItem is in collection, +check name?
    if item.id?
      #if item is on top
      item.command.dispose()
      if @items.inc == (@items.inc-1)
        delete @items[item.id]
      #else swap deletet with top item
      else
        @items[item.id] = @items[(@items.inc-1)]
        delete @items[(@items.inc-1)]
      @items.inc--
      @removeCheck item
      @eb.statusBarContainerView.remove item
      # @eventBus.emit 'status-bar-container-view:remove', item
      return true
    else return false
  removeCheck: (item) =>
    if item.cmdCheck? and item.cmdCheck.length>0
      checks = @checks[item.cmdCheck]
      if checks.length>1
        for value,key in checks
          if item.id == value.id
            checks.splice key,1
            return true
      else
        delete @checks[item.cmdCheck]
        return true
    return false

  addCommands: (item) ->
    item.command = atom.commands.add 'atom-workspace',"smart-daemon-control:configure-#{item.name}", =>
      # console.log @items, item
      @eb.daemonItemConfigureView.show @items[item.id]
      # @eventBus.emit 'daemon-item-configure-view:show', @items[item.id]
