$(document).on "mozfullscreenchange webkitfullscreenchange fullscreenchange", (ev) ->
  is_fullscreen = document.mozFullScreen || document.webkitIsFullScreen
  if is_fullscreen
    $(".video-controls-fullscreen").addClass("hide")
    $(".video-controls-unfullscreen").removeClass("hide")
  else
    $(".video-controls-unfullscreen").addClass("hide")
    $(".video-controls-fullscreen").removeClass("hide")

$ ->
  $video = $("video").first()
  video = $video[0]
  return if !video

  videoId = $video.attr("id")
  left_off_at_path = $video.data("left-off-at-path")
  last_time = parseInt($video.data("resume-from"), 10)

  setLeftOffAt = (e) ->
    $.post left_off_at_path,
      left_off_at: parseInt(e.currentTarget.currentTime, 10)
  throttledSetLeftOffAt = _.throttle(setLeftOffAt, 500)

  # http://www.w3.org/TR/html5/embedded-content-0.html#mediaevents
  $progress = $(".video-controls-progress")
  $video.on "timeupdate", (e) ->
    throttledSetLeftOffAt(e)
    progress = video.currentTime / video.duration
    $progress.width("#{progress*100}%")

  $video.one "canplay", (e) ->
    $video[0].currentTime = last_time if last_time

  $video.on "pause", (e) ->
    $(".video-controls-pause").addClass("hide")
    $(".video-controls-play").removeClass("hide")
    showMeta()

  $video.on "play", (e) ->
    $(".video-controls-play").addClass("hide")
    $(".video-controls-pause").removeClass("hide")
    hideMeta()

  $(".video-controls-progressbar").on "click", (e) ->
    clickedRatio = (e.offsetX / $(e.currentTarget).width())
    video.currentTime = clickedRatio * video.duration

  $(".video-controls-volumebar").on "click", (e) ->
    clickedRatio = (e.offsetX / $(e.currentTarget).width())
    video.volume = Math.max(0, Math.min(clickedRatio, 1))

  $video.on "volumechange", ->
    muted = video.volume == 0
    $(".video-controls-volume").width("#{video.volume * 100}%")
    if muted
      $(".video-controls-mute").addClass("hide")
      $(".video-controls-unmute").removeClass("hide")
    else
      $(".video-controls-unmute").addClass("hide")
      $(".video-controls-mute").removeClass("hide")

  $("#restart").on "click", ->
    $(this).blur()
    video.currentTime = 0
    video.play()

  $(".video-controls-mute").on "click", ->
    video.volume = 0

  $(".video-controls-unmute").on "click", ->
    video.volume = 1

  $(".video-controls-play").on "click", -> video.play()
  $(".video-controls-pause").on "click", -> video.pause()
  $(".video-controls-fullscreen").on "click", ->
    element = document.body
    element.webkitRequestFullscreen?(Element.ALLOW_KEYBOARD_INPUT)
    element.mozRequestFullScreen?()
    element.msRequestFullscreen?()
    element.requestFullscreen?()
  $(".video-controls-unfullscreen").on "click", ->
    document.webkitExitFullscreen?()
    document.mozCancelFullscreen?()
    document.msExitFullscreen?()
    document.exitFullscreen?()

  controlTimeout = null
  showControls = ->
    $(".video-controls").show()
    clearTimeout(controlTimeout)
    controlTimeout = setTimeout ->
      hideControls()
    , 2000

  hideControls = ->
    $(".video-controls").fadeOut()

  hideControls()

  $(document).on "keydown mousemove", ->
    clearTimeout(controlTimeout)
    showControls()


  hideMeta = (ms = 2000) ->
    $(".video-watch-meta").addClass("hidden");

  showMeta = ->
    $(".video-watch-meta").removeClass("hidden")

  $(document).on "keydown", (ev) ->
    switch ev.which
      when 32 # space
        if video.paused
          video.play()
        else
          video.pause()

  return
