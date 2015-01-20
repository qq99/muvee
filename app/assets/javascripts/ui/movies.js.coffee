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
          $(".featured-image .movie-background").addClass("hidden")
          $(".featured-image").append($img)
          _.defer ->
            $img.removeClass("hidden")
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
