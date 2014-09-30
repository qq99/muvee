startSimpleSlideshow = (el) ->
  $parent = $(el).find(".thumbnails")
  clearInterval window.slideshow
  window.slideshow = setInterval ->
    $shown = $parent.find(".video-thumbnail:not(.hidden)")
    $next = $shown.next()
    if !$next.length
      $next = $parent.find(".video-thumbnail").first()
    $shown.addClass("hidden")
    $next.removeClass("hidden")
  , 1500

stopSimpleSlideshow = ->
  clearInterval(window.slideshow)

$(document).on "focus mouseenter", ".js-has-thumbnails", (e) ->
  startSimpleSlideshow(e.currentTarget)

$(document).on "mouseleave blur", ".js-has-thumbnails", (e) ->
  stopSimpleSlideshow()

$(document).on "click", ".js-favourite-toggle", (e) ->
  e.preventDefault()
  $link = $(e.currentTarget)
  $icon = $link.find("i")
  if $icon.hasClass 'is-favourite'
    io.socket.delete $link.data("href"), ->
      $icon.removeClass("is-favourite")
      $icon.removeClass("fa-heart").addClass("fa-heart-o")
  else
    io.socket.post $link.data("href"), ->
      $icon.addClass("is-favourite")
      $icon.removeClass("fa-heart-o").addClass("fa-heart")

$(document).on "keydown", "#series-search-input", (e) ->
  if e.which == 13 # enter
    $("#series-search-execute").click()

$ ->
  $(".js-get-thumbnails:not(.has-thumbnails)").one "mouseenter focus", (e) ->
    $target = $(e.currentTarget)
    $container = $target.find(".thumbnails")

    $.get $target.data("thumbnail-path"), (response) ->
      if !response.thumbnails
        console.error "No thumbnails in response"
        return

      for url in response.thumbnails
        $img = $(".video-thumbnail").first().clone()
          .attr("src", "#{url}")
          .addClass("hidden")
        $container.append $img
