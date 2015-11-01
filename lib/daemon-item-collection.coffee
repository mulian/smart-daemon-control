DaemonItem = require "./daemon-item"

module.exports =
class DaemonItemCollection
  atom.deserializers.add(this)

  # @version: 0.1
  @deserialize: ({data,eventBus}) ->
    return new DaemonItemCollection eventBus, data
  serialize: ->
    return {} =
      deserializer: 'DaemonItemCollection'
      data:
        items: @items
        checks: @checks
      # version: @constructor.version

  constructor: (@eventBus,data) ->
    {@items,@checks}=data
    # data=undefined #reset list
    # console.log @checks
    @reqEventBus()
    if not data?
      @items = {} =
        inc: 0
      @checks = {}
    else
      for key,item of @items
        if key!='inc'
          @addCommands item
          @eventBus.emit 'daemon-control:run', {daemonItem:item,start:true} if item.autorun

  reqEventBus: ->
    @eventBus.on 'daemon-item-collection:add', @add
    @eventBus.on 'daemon-item-collection:remove', @remove
    @eventBus.on 'daemon-item-collection:change', @change
    @eventBus.on 'daemon-item-collection:get', @get
    @eventBus.on 'daemon-item-collection:new', @new
    @eventBus.on 'daemon-item-collection:checkStates', @checkStates

  checkStates: =>
    # checks = @checks.slice(0) #copy
    @eventBus.emit 'daemon-control:checkAll', @checks


  change: (item) =>
    console.log item
    @items[item.id] = item
    #TODO: status-bar checks: daemon-item-collection:change not like this
    @eventBus.emit 'status-bar-item-view:refresh', @items[item.id]

  new: =>
    newItem = new DaemonItem {name: "New"}
    @add newItem
    @eventbus.emit 'DaemonItemConfigureView.show', newItem

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
    @eventBus.emit 'status-bar-container-view:add', item
    @addCheck item
    return true
  addCheck: (item) ->
    @checks[item.cmdCheck]=[] if not @checks[item.cmdCheck]?
    @checks[item.cmdCheck].push item

  remove: (item) =>
    #if daemonItem is in collection, +check name?
    if item.id?
      #if item is on top
      if @items.inc == (@items.inc-1)
        delete @items[item.id]
      #else swap deletet with top item
      else
        @items[item.id] = @items[(@items.inc-1)]
        delete @items[(@items.inc-1)]
      @items.inc--
      @removeCheck item
      @eventBus.emit 'status-bar-container-view:remove', item
      return true
    else return false
  removeCheck: (item) ->
    checks = @checks[item.cmdCheck]
    if not checks.length>1
      delete @checks[item.cmdCheck]
      return true
    else
      for value,key in checks
        if item.id == value.id
          checks.splice key,1
          return true
    return false

  addCommands: (item) ->
    atom.commands.add 'atom-workspace',"smart-daemon-control:configure-#{item.name}", =>
      @eventBus.emit 'daemon-item-configure-view:show', item