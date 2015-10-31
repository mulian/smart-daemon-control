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
      data: @items
      # version: @constructor.version

  constructor: (@items) ->
    if not @items?
      @items = {} =
        inc: 0

  addEventBus: (@eventBus) ->
    @eventBus.on 'DaemonItemCollection.add', @add
    @eventBus.on 'DaemonItemCollection.remove', @remove
    @eventBus.on 'DaemonItemCollection.get', @get

  #If there is an id, return only item with id
  #else return collection
  get: (cb) =>
    for key,item of @items
      if key!='inc'
        console.log item
        cb item

  add: (item) =>
    item.id = @items.inc
    @items[item.id] = item
    @items.inc++
    @addCommands item
    return true

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
