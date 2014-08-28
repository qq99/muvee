$(document).on "click", ".js-find-sources", (ev) ->
  ev.preventDefault()
  $target = $(ev.currentTarget)
  src = $target.attr("href")
  $target.removeAttr("href")
  return if !src
  operation = $.ajax
    url: src,
    dataType: 'html',
    method: 'GET'

  operation.done (data, textStatus, jqXHR) ->
    $target.find(".js-sources-info").html(data).show()

$(document).on "click", ".js-sources-info", (ev) ->
  ev.preventDefault()
