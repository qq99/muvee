# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

torrentStatusInterval = null

document.addEventListener 'page:change', ->
  clearInterval torrentStatusInterval

  $torrentProgress = $(".torrent-progress-meter")

  if $torrentProgress.length
    torrentStatusInterval = setInterval ->
      $torrentProgress.each (i, el) ->
        $el = $(el)
        operation = $.ajax
          url: $el.data("torrent-progress-url")
          method: 'get'
          dataType: 'json'

        operation.done (data, textStatus, jqXHR) ->
          $el.find(".torrent-progress").width(data.percentage + "%")
          $el.find(".downloading").text(data.percentage + "%")
    , 2000
