Muvee.cable.subscriptions.create "TorrentInfoChannel",
  connected: ->
    @install()

  disconnected: ->
    @uninstall()

  rejected: ->
    @uninstall()

  received: (data) ->
    for result in data
      evt = new CustomEvent(
        "muvee:progress_reporter:TorrentInformation#{result.id}",
        {'detail': result}
      )
      document.dispatchEvent(evt)

  install: ->
    @torrentQueryInterval = setInterval =>
      @perform("torrent_info")
    , 1000

  uninstall: ->
    clearInterval @torrentQueryInterval
