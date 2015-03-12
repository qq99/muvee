class Muvee.ThumbnailRetriever
  THUMBNAIL_CONTAINER_CLASS: 'js-thumbnail-container'

  constructor: (@node, @thumbnailPath, @thumbnailExampleClass) ->
    @$container = $(".#{@THUMBNAIL_CONTAINER_CLASS}", @node)

    throw new Error("Unable to find a thumbnail container for node") if @$container.length == 0

    @$container.one "mouseenter.ThumbnailRetriever focus.ThumbnailRetriever", @retrieve.bind(this)

    Page.onReplace(@node, @destructor.bind(this))

  destructor: ->
    @$container.off "mouseenter.ThumbnailRetriever focus.ThumbnailRetriever"

  retrieve: ->
    return unless @thumbnailPath

    $.get @thumbnailPath, (response) =>
      if !response.thumbnails
        console.error "No thumbnails in response"
        return

      for url in response.thumbnails
        $thumb = $("#{@thumbnailExampleClass}", @node).first().clone()
          .attr("src", url)
          .removeAttr("data-src")
          .addClass("hidden")
        @$container.append $thumb

      return
