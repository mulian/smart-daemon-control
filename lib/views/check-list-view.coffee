{SelectListView} = require 'atom-space-pen-views'
$ = require 'jquery'

module.exports =
class CheckListView extends SelectListView

  initialize: (@attr) ->
    super
    #@addClass('overlay from-top')
    @title = $('<div />',{text: 'Title',id:'title'})
    @setItems([{title:'Hello'}, {title:'World'}])
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()
    #console.log @element
    $(@element).prepend @title

  getFilterKey: () ->
    "title"
  viewForItem: (item) ->
    "<li class='check-list-item'>#{item.title}<input type='checkbox'/></li>"

  confirmed: (item) ->
    console.log("#{item.title} was selected")

  cancelled: ->
    console.log("This view was cancelled")
