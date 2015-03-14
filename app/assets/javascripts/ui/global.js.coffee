onError = (jqXHR, textStatus, errorThrown) ->
  $(".modal.error .error-text").text(JSON.parse(jqXHR.responseText).status)
  $(".modal.error").addClass("show")

$(document).on "click", ".js-close-modal", ->
  $(".modal").removeClass("show")

$(document).on "click", "[data-modal]", (ev) ->
  ev.preventDefault()
  modalId = $(ev.currentTarget).data("modal")
  $("##{modalId}").addClass("show")


$ ->
  socket = new WebSocket "ws://#{window.location.host}/status/info"
  socket.onmessage = (event) ->

    try
      data = JSON.parse(event.data)

      if data.type == "VideoCreationService"
        evt = new CustomEvent("muvee:progress_reporter:VideoCreationService", {'detail': data})
        document.dispatchEvent(evt)

      else if data.type == "TorrentInformation"
        torrents = data.results

        for torrent in torrents
          $container = $("#torrent-progress-#{torrent.video_id}")
          $container.find(".progress-bar__bar").css("width", torrent.progress + "%")


    catch e
      console.log('Unable to parse as JSON', event.data)

  socket.onopen = (event) ->
    console.log 'Socket open.'

    setInterval ->
      socket.send(JSON.stringify(name: 'torrent_info'))
    , 1000

  socket.onclose = (event) ->
    console.log 'Socket closed.'
