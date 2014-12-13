movieSlideshow = null

transition = ($source) ->
  $(".featured-image .movie-background.hidden").remove()
  $images = $(".slideshow-pool .movie-background")
  return if $images.length == 0

  randomIndex = parseInt(Math.random()*$images.length, 10)
  $randomImg = $($images[randomIndex]).clone()
  src = $randomImg.attr("data-src")
  $randomImg.attr("style", "background: url(#{src})").addClass("hidden") if src


  $(".featured-image").append($randomImg)
  $(".featured-image .movie-background").addClass("hidden")
  _.defer ->
    $randomImg.removeClass("hidden")

# get metadata
$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  target = ev.currentTarget
  ctx = Twine.context(target)
  _.merge(window.context.movieMeta, ctx)
  Twine.refresh()

# get movie images, queue up slideshow
$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  clearInterval(movieSlideshow)
  target = ev.currentTarget
  $target = $(target)

  if key = $target.data("refresh-key")
    operation = $.ajax
      method: 'GET'
      url: $target.data("fanart-path")
      dataType: 'html'
    .done (data, textStatus, jqXHR) ->
      Page.refresh
        response: jqXHR
        onlyKeys: ['slideshow-pool']
      _.defer ->
        movieSlideshow = setInterval ->
          transition()
        , 5000
        transition()

document.addEventListener 'page:change', ->
  clearInterval(movieSlideshow)
  _.defer -> $(".js-movie-tile").first().trigger("focus")
  transition() # for movies#show
