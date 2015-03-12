class Muvee.VideoPlayer
  constructor: (@node, @opts) ->
    @fullscreen = false
    @setLeftOffAtTime = _.throttle(@_setLeftOffAtTime.bind(this), 1000)
    @videoEl = $(@node).find("video")[0]

    params = URI(document.location).search(true)

    if params.t
      stripped = URI(document.location).query('').toString()
      history.replaceState({}, null, stripped)
      startAt = parseInt(params.t, 10)
    else
      startAt = @opts.resumeFrom

    # HTML5 video events: http://www.w3.org/TR/html5/embedded-content-0.html#mediaevents
    $(@videoEl).one "canplay.VideoPlayer", =>
      unless @opts.duration && (@opts.duration - startAt) < 30 # don't set time if we're already near the end
        @setCurrentTime(startAt)

    $(@videoEl).on "pause.VideoPlayer", =>
      if @secondsLeft() < 1
        document.getElementById("next-episode-link").click()
      else
        #brightenLights()

    $(@videoEl).on "timeupdate.VideoPlayer", _.throttle =>
      Twine.refresh()
      @setLeftOffAtTime()
      @updateDurationBar()
    , 250

    $(@videoEl).on "play.VideoPlayer", =>
      Twine.refresh()

    $(@videoEl).on "volumechange.VideoPlayer", =>
      Twine.refresh()
      @updateVolumeBar()

    $(document).on "keydown mousemove", @showControls.bind(this)

    $(document).on "keydown.VideoPlayer", (ev) =>
      switch ev.which
        when 32 # space
          @togglePlayPause()
        when 37 # left arrow
          @stepBackwards()
        when 39 # right arrow
          @stepForwards()
        when 40 # up arrow
          @videoEl.volume = Math.max(0, @videoEl.volume - 0.05)
        when 38 # down arrow
          @videoEl.volume = Math.min(1.0, @videoEl.volume + 0.05)

    Page.onReplace @node, @destructor

  destructor: ->
    $(document).off(".VideoPlayer")

  play: ->
    @videoEl.play()

  pause: ->
    @videoEl.pause()

  paused: ->
    !!@videoEl.paused

  playing: ->
    !@paused()

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
    @videoEl.volume = Math.max(0, Math.min(clickedRatio, 1))

  updateVolumeBar: ->
    $("#volume-bar .progress-bar__bar", @node).css("width", "#{@percentageVolume()}%")

  toggleMute: ->
    if @muted()
      @videoEl.volume = @previousVolume || 1
    else
      @previousVolume = @videoEl.volume
      @videoEl.volume = 0

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
    $.post @opts.leftOffAtPath,
      left_off_at: parseInt(@videoEl.currentTime, 10)

  showControls: ->
    @shouldShowControls = true
    clearTimeout(@controlTimeout)
    @controlTimeout = setTimeout =>
      @shouldShowControls = false
    , 4000
