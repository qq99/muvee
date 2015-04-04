class Muvee.MuveeSocket
  constructor: ->
    @reconnect()

  onMessage: (event) =>
    try
      data = JSON.parse(event.data)

      if data.type == "VideoCreationService"
        evt = new CustomEvent("muvee:progress_reporter:VideoCreationService", {'detail': data})
        document.dispatchEvent(evt)

      else if data.type == "SeriesDiscoveryWorker"
        evt = new CustomEvent("muvee:progress_reporter:SeriesDiscoveryWorker", {'detail': data})
        document.dispatchEvent(evt)

      else if data.type == "TorrentInformation"
        torrents = data.results
        for data in torrents
          evt = new CustomEvent("muvee:progress_reporter:TorrentInformation#{data.id}", {'detail': data})
          document.dispatchEvent(evt)
    catch e
      console.log('Unable to parse as JSON', event.data)

  onClose: =>
    console.log 'Socket closed.'
    @reconnect()

  onOpen: =>
    console.log 'Socket opened.'
    @resetReconnectDelay()

    socketInterval = setInterval =>
      if @socket.readyState == @socket.OPEN
        @socket.send(JSON.stringify(name: 'torrent_info'))
      else
        clearInterval socketInterval
    , 1000

  resetReconnectDelay: ->
    @currentPoT = 0

  incrementReconnectDelay: ->
    @currentPoT ||= 0
    @currentPoT += 1
    @currentPoT = Math.min(@currentPoT, 8) # min 2^1,2^n,...,2^8 max

    @currentReconnectDelay = Math.pow(2, @currentPoT) * 1000 # seconds

  reconnect: ->
    @incrementReconnectDelay()
    setTimeout =>
      console.log 'Attempting to reconnect socket'
      @socket = @createSocket()
    , @currentReconnectDelay


  createSocket: ->
    socketInterval = null
    socket = new WebSocket "ws://#{window.location.host}/status/info"
    socket.onmessage = @onMessage
    socket.onopen = @onOpen
    socket.onclose = @onClose
    socket
