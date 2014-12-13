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
  target = ev.currentTarget
  $target = $(target)

  ctx = Twine.context(target)
  _.merge(window.context.movieMeta, ctx)
  Twine.refresh()

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

  movieSlideshow = setInterval ->
    transition($target)
  , 5000
