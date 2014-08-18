$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  $target = $(ev.currentTarget)
  $(".movie-meta .movie-title").html($target.data("title"))
  $(".movie-meta .movie-overview").html($target.data("overview"))
  $(".inline-movie-preview .movie-images").html($target.find(".thumbnails").html())
  $(".inline-movie-preview .movie-images img").first().removeClass("hide")
  $(".inline-movie-preview").addClass("active")

$ ->
  $(".js-movie-tile").first().trigger("focus")
