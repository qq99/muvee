$(document).on 'page:fetch', -> NProgress.start()
$(document).on 'page:change', -> NProgress.done()
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

$(document).on 'click', '[remote-method]', (event) ->
  event.preventDefault()

  $link = $(this)

  requestType = $link.attr('remote-method')
  httpRequestType = if requestType.toLowerCase() == 'get' then 'GET' else 'POST'

  ajaxOptions =
    type: httpRequestType
    url: $link.attr('href')
    dataType: 'html'
    data:
      '_method': requestType

  remote = new Turbograft.Remote(ajaxOptions, $link.attr("refresh-on-success"), $link.attr("refresh-on-error"), $link.attr("full-refresh"))
  remote.submit()

window.Turbograft = {};
class Turbograft.Remote
  constructor: (@ajaxOptions = {}, @refreshOnSuccess, @refreshOnError, @fullRefresh = false) ->

  submit: =>
    operation = $.ajax @ajaxOptions

    operation.done (results, status, xhr) =>
      if redirect = xhr.getResponseHeader('X-Next-Redirect')
        Page.visit(redirect, reload: true)
        return

      @ajaxOptions.done?.apply(null, arguments)

      refreshKeys = if @refreshOnSuccess then @refreshOnSuccess.split(" ") else []
      if @fullRefresh
        Page.refresh
          onlyKeys: refreshKeys
      else if @refreshOnSuccess != "false"
        Page.refresh
          response: xhr
          onlyKeys: refreshKeys

    operation.fail (jqXHR, textStatus, errorThrown) =>
      @ajaxOptions.fail?.apply(null, arguments)
      if @refreshOnError != "false"
        if @refreshOnError
          Page.refresh
            response: jqXHR
            onlyKeys: @refreshOnError.split(" ")

    return
