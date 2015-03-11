document.addEventListener 'page:change', ->
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
