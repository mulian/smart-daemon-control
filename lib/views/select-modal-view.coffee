{SelectListView,View} = require 'atom-space-pen-views'
CheckListView = require './check-list-view'
$ = require 'jquery'

module.exports =
class SelectModalView extends View
  @content: ->
    @div id:"select-modal-title", "title"
    @div id:'select-modal-checklist'

  initialize: (@attr) ->
    @checkListView = new checkListView()
    $('#select-modal-checklist').append @checkListView
  run: ->
