$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  $target = $(ev.currentTarget)
  $(".movie-meta .movie-title .title").html($target.data("title"))
  $(".movie-meta .movie-overview").html($target.data("overview"))
  $(".inline-movie-preview .movie-images").html($target.find(".thumbnails").html())

  if $target.data("3d")
    $(".movie-meta .three-d").show()
  else
    $(".movie-meta .three-d").hide()

  $(".inline-movie-preview .movie-images img").first().removeClass("hide")
  $(".inline-movie-preview").addClass("active")

$ ->
  $(".js-movie-tile").first().trigger("focus")
