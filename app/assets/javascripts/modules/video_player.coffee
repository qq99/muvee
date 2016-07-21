class Muvee.VideoPlayer
  constructor: (@node, @opts) ->
    @fullscreen = false
    @onTimeUpdate = _.throttle(@_onTimeUpdate, 250)
    @setLeftOffAtTime = _.throttle(@_setLeftOffAtTime.bind(this), 1000)
    @videoEl = $(@node).find("video")[0]

    @volumePreference = parseFloat(localStorage.getItem("volume-preference")) || 1.0

    params = URI(document.location).search(true)

    if params.t
      stripped = URI(document.location).query('').toString()
      history.replaceState({}, null, stripped)
      startAt = parseInt(params.t, 10)
    else
      startAt = @opts.resumeFrom

    @setVolume(@volumePreference)

    unless @opts.duration && (@opts.duration - startAt) < 30 # don't set time if we're already near the end
      @setCurrentTime(startAt)

    @play()

    @bindEvents()

    Page.onReplace @node, @destructor

  bindEvents: ->
    # HTML5 video events: http://www.w3.org/TR/html5/embedded-content-0.html#mediaevents
    @videoEl.addEventListener 'pause', @onPause
    @videoEl.addEventListener 'timeupdate', @onTimeUpdate
    @videoEl.addEventListener 'play', @onPlay
    @videoEl.addEventListener 'volumechange', @onVolumeChange
    document.addEventListener 'keydown', @showControls
    document.addEventListener 'mousemove', @showControls
    document.addEventListener 'keydown', @onKeyDown

  destructor: =>
    @videoEl.removeEventListener('pause', @onPause)
    @videoEl.removeEventListener('play', @onPlay)
    @videoEl.removeEventListener('timeupdate', @onTimeUpdate)
    @videoEl.removeEventListener('volumechange', @onTimeUpdate)
    document.removeEventListener('keydown', @showControls)
    document.removeEventListener('mousemove', @showControls)
    document.removeEventListener('keydown', @onKeyDown)

  play: ->
    @videoEl.play()

  onPlay: ->
    Twine.refresh()

  pause: ->
    @videoEl.pause()

  onPause: =>
    document.getElementById("next-episode-link").click() if @secondsLeft() < 1

  paused: ->
    !!@videoEl.paused

  playing: ->
    !@paused()

  _onTimeUpdate: =>
    Twine.refresh()
    @setLeftOffAtTime()
    @updateDurationBar()

  onKeyDown: (ev) =>
    switch ev.which
      when 32 # space
        @togglePlayPause()
      when 37 # left arrow
        @stepBackwards()
      when 39 # right arrow
        @stepForwards()
      when 40 # up arrow
        @setVolume(@videoEl.volume - 0.05)
      when 38 # down arrow
        @setVolume(@videoEl.volume + 0.05)

  muted: ->
    @videoEl.volume == 0

  restart: ->
    @videoEl.currentTime = 0
    @videoEl.play() if @paused()

  togglePlayPause: ->
    if @paused()
      @play()
    else
      @pause()

  setCurrentTime: (seconds) ->
    @videoEl.currentTime = seconds
    @updateDurationBar()

  stepBackwards: (nSeconds = 30) ->
    @setCurrentTime(Math.max(0, @videoEl.currentTime - nSeconds))

  stepForwards: (nSeconds = 30) ->
    @setCurrentTime(Math.min(@videoEl.currentTime + nSeconds, @videoEl.duration))

  clickDurationBar: (ev) ->
    clickedRatio = (ev.offsetX / $(ev.currentTarget).width())
    @setCurrentTime(clickedRatio * @videoEl.duration)

  updateDurationBar: ->
    $("#duration-bar .progress-bar__bar", @node).css("width", "#{@percentagePlayed()}%")

  clickVolumeBar: (ev) ->
    clickedRatio = (ev.offsetX / $(ev.currentTarget).width())
    @setVolume(clickedRatio)

  setVolume: (newVolume) ->
    @videoEl.volume = Math.max(0, Math.min(newVolume, 1))
    localStorage.setItem("volume-preference", @videoEl.volume)

  onVolumeChange: =>
    Twine.refresh()
    @updateVolumeBar()

  updateVolumeBar: ->
    $("#volume-bar .progress-bar__bar", @node).css("width", "#{@percentageVolume()}%")

  toggleMute: ->
    if @muted()
      @setVolume(@previousVolume || 1)
    else
      @previousVolume = @videoEl.volume
      @setVolume(0)

  secondsToHuman: (seconds) ->
    hours = parseInt(seconds / (60*60), 10)
    minutes = parseInt((seconds - (hours*60*60)) / 60, 10)
    seconds = parseInt(seconds - (hours*60*60) - (minutes*60), 10)
    [hours, minutes, seconds]

  toDuration: (hours, minutes, seconds) ->
    h = hours.toString()
    m = minutes.toString()
    s = seconds.toString()
    pad = "00"
    dur =
      pad.substring(0, 2 - h.length) + h + ":" +
      pad.substring(0, 2 - m.length) + m + ":" +
      pad.substring(0, 2 - s.length) + s

  percentageVolume: ->
    @videoEl.volume * 100

  percentagePlayed: ->
    (@videoEl.currentTime / @videoEl.duration) * 100

  videoDuration: ->
    @videoEl.duration || 0

  secondsLeft: ->
    parseInt(@videoDuration() - @videoEl.currentTime, 10)

  durationRemaining: ->
    @toDuration.apply(this, @secondsToHuman(@secondsLeft()))

  enableFullscreen: ->
    el = document.body
    el.webkitRequestFullscreen?(Element.ALLOW_KEYBOARD_INPUT)
    el.mozRequestFullScreen?()
    el.msRequestFullscreen?()
    el.requestFullscreen?()
    @fullscreen = true

  disableFullscreen: ->
    document.webkitExitFullscreen?()
    document.mozCancelFullscreen?()
    document.msExitFullscreen?()
    document.exitFullscreen?()
    @fullscreen = false

  toggleFullscreen: ->
    if @fullscreen
      @disableFullscreen()
    else
      @enableFullscreen()

  showUpnext: ->
    @secondsLeft() < 15

  _setLeftOffAtTime: ->
    Muvee.videoStatusCable.perform("set_left_off_at",
      video_id: @opts.videoId,
      left_off_at: parseInt(@videoEl.currentTime, 10)
    )

  showControls: =>
    @shouldShowControls = true
    clearTimeout(@controlTimeout)
    @controlTimeout = setTimeout =>
      @shouldShowControls = false
    , 4000
