controlTimeout = null
showControls = ->
  $(".video-controls, .video-back-button").removeClass('hide')
  clearTimeout(controlTimeout)
  controlTimeout = setTimeout ->
    hideControls()
  , 4000

hideControls = ->
  $(".video-controls, .video-back-button").addClass('hide')

hideMeta = (ms = 2000) ->
  $(".video-watch-meta").addClass("hidden")

showMeta = ->
  $(".video-watch-meta").removeClass("hidden")

secondsToHuman = (seconds) ->
  hours = parseInt(seconds / (60*60), 10)
  minutes = parseInt((seconds - (hours*60*60)) / 60, 10)
  seconds = parseInt(seconds - (hours*60*60) - (minutes*60), 10)
  [hours, minutes, seconds]

toDuration = (hours, minutes, seconds) ->
  h = hours.toString()
  m = minutes.toString()
  s = seconds.toString()
  pad = "00"
  dur =
    pad.substring(0, 2 - h.length) + h + ":" +
    pad.substring(0, 2 - m.length) + m + ":" +
    pad.substring(0, 2 - s.length) + s

$(document).on "keydown mousemove", ->
  clearTimeout(controlTimeout)
  showControls()

$(document).on "mozfullscreenchange webkitfullscreenchange fullscreenchange", (ev) ->
  is_fullscreen = document.mozFullScreen || document.webkitIsFullScreen
  if is_fullscreen
    $(".video-controls-fullscreen").addClass("hide")
    $(".video-controls-unfullscreen").removeClass("hide")
  else
    $(".video-controls-unfullscreen").addClass("hide")
    $(".video-controls-fullscreen").removeClass("hide")

document.addEventListener 'page:change', ->
  uri = URI(document.location)
  params = uri.search(true)

  # unbind, because turbolinks :(
  $video?.off(".videoplayer")
  $(document).off(".videoplayer")

  $video = $("video").first()
  video = $video[0]
  return if !video

  left_off_at_path = $video.data("left-off-at-path")
  last_time = params.t || parseInt($video.data("resume-from"), 10)

  if params.t
    stripped = URI(document.location).query('').toString()
    history.replaceState({}, null, stripped)

  setLeftOffAt = (e) ->
    $.post left_off_at_path,
      left_off_at: parseInt(e.currentTarget.currentTime, 10)
  throttledSetLeftOffAt = _.throttle(setLeftOffAt, 500)

  # http://www.w3.org/TR/html5/embedded-content-0.html#mediaevents
  $progress = $(".video-controls-progress")
  timeRemaining = $(".js-time-remaining")[0]
  $video.on "timeupdate.videoplayer", _.throttle (e) ->
    throttledSetLeftOffAt(e)
    progress = video.currentTime / video.duration
    $progress.width("#{progress*100}%")

    timeLeft = video.duration - video.currentTime

    if timeLeft < 15
      $(".video-upnext").removeClass("hide hidden")
      $(".starting-in").text("Starting in #{parseInt(timeLeft, 10)} seconds")
    else
      $(".video-upnext").addClass("hide hidden")

    [hours, minutes, seconds] = secondsToHuman(timeLeft)
    timeRemaining.textContent = toDuration(hours, minutes, seconds)
  , 250 # probably often enough


  $video.one "canplay.videoplayer", (e) ->
    $video[0].currentTime = last_time if last_time

  $video.on "pause.videoplayer", (e) ->
    $(".video-controls-pause").addClass("hide")
    $(".video-controls-play").removeClass("hide")
    showMeta()
    timeLeft = video.duration - video.currentTime
    if timeLeft < 1
      document.getElementById("next-episode-link").click()

  $video.on "play.videoplayer", (e) ->
    $(".video-controls-play").addClass("hide")
    $(".video-controls-pause").removeClass("hide")
    hideMeta()

  $(".video-controls-progressbar").on "click.videoplayer", (e) ->
    clickedRatio = (e.offsetX / $(e.currentTarget).width())
    video.currentTime = clickedRatio * video.duration

  $(".video-controls-volumebar").on "click.videoplayer", (e) ->
    clickedRatio = (e.offsetX / $(e.currentTarget).width())
    video.volume = Math.max(0, Math.min(clickedRatio, 1))

  $(".video-controls-stepback").on "click.videoplayer", (e) ->
    video.currentTime = Math.max(0, video.currentTime - 30)

  $(document).on "keydown.videoplayer", (ev) ->
    switch ev.which
      when 32 # space
        if video.paused
          video.play()
        else
          video.pause()
      when 37 # left arrow
        video.currentTime = Math.max(0, video.currentTime - 10)
      when 39
        video.currentTime = Math.min(video.currentTime + 10, video.duration)
      when 189 # -
        video.volume = Math.max(0, video.volume - 0.05)
      when 187 # +
        video.volume = Math.min(1.0, video.volume + 0.05)

  $video.on "volumechange.videoplayer", ->
    muted = video.volume == 0
    $(".video-controls-volume").width("#{video.volume * 100}%")
    if muted
      $(".video-controls-mute").addClass("hide")
      $(".video-controls-unmute").removeClass("hide")
    else
      $(".video-controls-unmute").addClass("hide")
      $(".video-controls-mute").removeClass("hide")

  $("#restart").on "click.videoplayer", ->
    $(this).blur()
    video.currentTime = 0
    video.play()

  $(".video-controls-mute").on "click.videoplayer", ->
    video.volume = 0

  $(".video-controls-unmute").on "click.videoplayer", ->
    video.volume = 1

  $(".video-controls-play").on "click.videoplayer", -> video.play()
  $(".video-controls-pause").on "click.videoplayer", -> video.pause()
  $(".video-controls-fullscreen").on "click.videoplayer", ->
    element = document.body
    element.webkitRequestFullscreen?(Element.ALLOW_KEYBOARD_INPUT)
    element.mozRequestFullScreen?()
    element.msRequestFullscreen?()
    element.requestFullscreen?()
  $(".video-controls-unfullscreen").on "click.videoplayer", ->
    document.webkitExitFullscreen?()
    document.mozCancelFullscreen?()
    document.msExitFullscreen?()
    document.exitFullscreen?()



  return
