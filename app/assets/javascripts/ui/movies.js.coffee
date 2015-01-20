setBackground = ($node, url = '') ->
  url ||= $node.data("background-url")
  $node.attr("style", "background-image: url(#{url})")

getNewBackground = (ev) ->
  target = ev.currentTarget
  $target = $(target)

  if key = $target.data("refresh-key")
    operation = $.ajax
      method: 'GET'
      url: $target.data("fanart-path")
      dataType: 'json'
    .done (data, textStatus, jqXHR) ->
      idx = parseInt(Math.random() * (data.length - 1), 10)
      src = data[idx]
      $img = $("<img></img>")
        .attr("class", "movie-background hidden")
        .one("load", (ev) ->
          $slide = $("<div class='movie-background hidden'></div>")
          setBackground($slide, src)
          $(".featured-image.movies-index .movie-background").addClass("hidden")
          $(".featured-image.movies-index").append($slide)
          _.defer ->
            $slide.removeClass("hidden")
        )
        .attr("src", src)

# get movie fanarts
$(document).on "focus mouseenter", ".js-movie-tile", _.debounce(getNewBackground, 500)

# get metadata and set it in the right spot
$(document).on "focus mouseenter", ".js-movie-tile", (ev) ->
  target = ev.currentTarget
  ctx = Twine.context(target)
  _.merge(window.context.movieMeta, ctx)
  Twine.refresh()


# movie#show

transition = ($slideshow) ->
  $next = $slideshow.find(".movie-background:not(.hidden)").next()
  $next = $slideshow.find(".movie-background").first() if $next.length == 0

  setBackground($next)
  setBackground($next.next())

  $next.prev().addClass("hidden")
  $next.removeClass("hidden")

$(document).on "page:change", ->
  $slideshow = $(".js-auto-slideshow")
  clearInterval(window.movieArtSlideshow)

  if $slideshow.length
    transition($slideshow)
    window.movieArtSlideshow = setInterval ->
      transition($slideshow)
    , 7000
