movieSlideshow = null

$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  clearInterval(movieSlideshow)

  $target = $(ev.currentTarget)
  $(".movie-meta .movie-title .title").html($target.data("title"))
  $(".movie-meta .movie-overview").html($target.data("overview"))
  $(".movie-meta .movie-quality").html($target.data("quality"))
  $(".movie-meta .movie-year").html($target.data("year"))
  $(".inline-movie-preview .featured-image").html($target.find(".thumbnails").html())

  operation = $.ajax
    method: 'GET'
    url: $target.data("fanart-path")
    dataType: 'html'

  operation.done (data, textStatus, jqXHR) ->
    $(".inline-movie-preview .slideshow-pool").html(data)

  if $target.data("3d")
    $(".movie-meta .three-d").show()
  else
    $(".movie-meta .three-d").hide()

  $(".inline-movie-preview .movie-images img").first().removeClass("hide")
  $(".inline-movie-preview").addClass("active")

  movieSlideshow = setInterval ->
    $images = $(".slideshow-pool img")
    return if !$images.length

    randomIndex = parseInt(Math.random()*$images.length, 10)
    randomImg = $images[randomIndex]
    console.log randomIndex

    $(".featured-image img").remove()
    $(".featured-image").html(randomImg)
  , 5000

$ ->
  $(".js-movie-tile").first().trigger("focus")
