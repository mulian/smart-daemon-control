DaemonItem = require "./daemon-item"

module.exports =
class DaemonItemCollection
  atom.deserializers.add(this)

  # @version: 0.1
  @deserialize: ({data}) ->
    return new DaemonItemCollection(data)
  serialize: ->
    return {} =
      deserializer: 'DaemonItemCollection'
      data:
        items: @items
        checks: @checks
      # version: @constructor.version

  constructor: (data) ->
    {@items,@checks}=data
    # data=undefined #reset list
    console.log @checks
    if not data?
      @items = {} =
        inc: 0
      @checks = {}

  addEventBus: (@eventBus) ->
    @eventBus.on 'daemon-item-collection:add', @add
    @eventBus.on 'daemon-item-collection:remove', @remove
    @eventBus.on 'daemon-item-collection:get', @get
    @eventBus.on 'daemon-item-collection:new', @new
    @eventBus.on 'daemon-item-collection:checkStates', @checkStates

  checkStates: =>
    # checks = @checks.slice(0) #copy
    @eventBus.emit 'daemon-control:checkAll', @checks


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
    console.log "add:"
    console.log item
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
      if @item.id == (@items.inc-1)
        delete @items[item.id]
      #else swap deletet with top item
      else
        @items[item.id] = @items[(@items.inc-1)]
        delete @items[(@items.inc-1)]
      @items.inc--
      return true
    else return false

  addCommands: (item) ->
    atom.commands.add 'atom-workspace',"smart-daemon-control:configure-#{item.name}", =>
      @eventBus.emit 'DaemonManagement.showItemConfig', item
