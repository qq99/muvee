movieSlideshow = null

transition = ($source) ->
  $(".featured-image img.hidden").remove()
  $images = $source.find(".thumbnails img")
  return if !$images.length

  randomIndex = parseInt(Math.random()*$images.length, 10)
  $randomImg = $($images[randomIndex]).clone()
  $randomImg.attr("src", $randomImg.attr("data-src")).addClass("hidden")

  $(".featured-image img").addClass("hidden")
  $(".featured-image").append($randomImg)
  _.defer ->
    $randomImg.removeClass("hidden")

$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  clearInterval(movieSlideshow)

  $target = $(ev.currentTarget)
  $(".movie-meta .movie-title .title").html($target.data("title"))
  $(".movie-meta .movie-overview").html($target.data("overview"))
  $(".movie-meta .movie-quality").html($target.data("quality"))
  $(".movie-meta .movie-year").html($target.data("year"))

  transition($target)

  if key = $target.data("refresh-key")
    $target.data("refresh-key", "")
    operation = $.ajax
      method: 'GET'
      url: $target.data("fanart-path")
      dataType: 'html'

    operation.done (data, textStatus, jqXHR) ->
      Page.refresh
        response: jqXHR
        onlyKeys: [key]

  if $target.data("3d")
    $(".movie-meta .three-d").show()
  else
    $(".movie-meta .three-d").hide()

  $(".inline-movie-preview .movie-images img").first().removeClass("hide")
  $(".inline-movie-preview").addClass("active")


  movieSlideshow = setInterval ->
    transition($target)
  , 5000
