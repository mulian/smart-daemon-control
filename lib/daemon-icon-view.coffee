module.exports =
class DaemonIconView
  element : null

  constructor : (@serializedState,@name,@path) ->
    @element = document.createElement('span')
    #@element.className = "inline-block"
    @element.classList.add('launchd-controll-daemon-icon')
    @element.textContent = @name

  start : () ->
    
