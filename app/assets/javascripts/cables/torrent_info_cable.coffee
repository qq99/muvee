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
    @pageChangeListener = document.addEventListener 'page:load', @getInfo.bind(this)
    @torrentQueryInterval = setInterval(@getInfo.bind(this), 1000)

  getInfo: -> @perform("torrent_info")

  uninstall: ->
    clearInterval @torrentQueryInterval
    document.removeEventListener(@pageChangeListener)
