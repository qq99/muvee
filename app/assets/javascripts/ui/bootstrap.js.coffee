$(document).on 'page:fetch turbograft:remote:start', -> NProgress.start()
$(document).on 'page:change turbograft:remote:always', -> NProgress.done()
$(document).on 'page:restore', -> NProgress.remove()
$(document).on 'page:before-partial-replace', -> NProgress.done()
$(document).on 'submit', (ev) ->
  NProgress.start()

$ ->
  $.ajaxSetup
    headers:
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')

# Twine & Turbograft interop:
window.context = {}

reset = (nodes) ->
  if nodes
    Twine.bind(node) for node in nodes # bind the new nodes
  else
    Twine.reset(context).bind()

  Twine.refreshImmediately()
  return

document.addEventListener 'DOMContentLoaded', -> reset()

document.addEventListener 'page:load', (event) ->
  reset(event.data)
  return

document.addEventListener 'page:before-partial-replace', (event) ->
  nodes = event.data
  Twine.unbind(node) for node in nodes # remove listeners on nodes that will disappear
  return

$(document).ajaxComplete ->
  Twine.refresh()
