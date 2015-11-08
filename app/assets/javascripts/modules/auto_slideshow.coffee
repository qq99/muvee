class Muvee.AutoSlideshow

  SLIDE_CLASS: 'js-slide'
  SLIDE_HIDDEN_CLASS: 'hidden'

  constructor: (@node, @interval = 7000) ->
    @$slideshow = $(@node)

    Page.onReplace(@node, @destructor.bind(this))

  destructor: ->
    @stop()

  loadSlideImage: ($node) ->
    if url = $node.data("background-url")
      $node.attr("style", "background-image: url(#{url})")
      $node.removeAttr('data-background-url')
    else if url = $node.data("src")
      $node.attr("src", url)
      $node.removeAttr('data-src')

  transition: ->
    $next = @$slideshow.find(".#{@SLIDE_CLASS}:not(.#{@SLIDE_HIDDEN_CLASS})").next()
    $next = @$slideshow.find(".#{@SLIDE_CLASS}").first() if $next.length == 0

    @loadSlideImage($next)
    @loadSlideImage($next.next()) # preload image after this

    @$slideshow.find(".#{@SLIDE_CLASS}").addClass(@SLIDE_HIDDEN_CLASS)
    $next.removeClass(@SLIDE_HIDDEN_CLASS)

    this

  start: ->
    @slideshowInterval = setInterval =>
      @transition()
    , @interval

    this

  stop: ->
    clearInterval(@slideshowInterval)
    this
