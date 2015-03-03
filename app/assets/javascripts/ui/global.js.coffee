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
  socket = new WebSocket "ws://#{window.location.host}/status"
  socket.onmessage = (event) ->

    try
      data = JSON.parse(event.data)
      #console.log(data)

      if data.type == "VideoCreationService"
        $parent = $("#scan-progress")
        $(".job-message", $parent).text(data.processing)
        $(".job-progress", $parent).text(parseInt(data.progress, 10) + "%")
        $(".job-current", $parent).text(data.current)
        $(".job-max", $parent).text(data.max)
        $(".progress-bar__bar", $parent).css("width", data.progress + "%")
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
