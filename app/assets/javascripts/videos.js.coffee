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

  $video.on "timeupdate", _.throttle(setLeftOffAt, 500)

  $video.one "canplay", (e) ->
    $video[0].currentTime = last_time if last_time

  hideMeta = (ms = 2000) ->
    setTimeout ->
      $(".meta").addClass("hidden");
    , ms

  showMeta = ->
    $(".meta").removeClass("hidden")
    hideMeta(8000)

  hideMeta()

  $(document).on "keydown", (ev) ->
    switch ev.which
      when 32 # space
        if video.paused
          video.play()
        else
          video.pause()

  $(document).on "mousemove keydown", ->
    showMeta()
    return

  return
