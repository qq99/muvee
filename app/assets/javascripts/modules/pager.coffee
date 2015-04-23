class Muvee.Pager

  NUM_TICKS = 8

  constructor: (@node) ->
    @currentPage = 0
    $(window).on "mousewheel.pager", _.throttle(@scrollLoad.bind(this), 50)

    @resetTicks()

    Page.onReplace @node, @destructor.bind(this)

  destructor: ->
    $(window).off "mousewheel.pager"

  resetTicks: ->
    @nextTicks = 0
    @prevTicks = 0

  scrollLoad: (ev) ->
    mousing_downwards = if ev.originalEvent.deltaY > 0 then true else false

    if mousing_downwards
      @prevTicks = 0

      if ($(window).scrollTop() + $(window).height()) >= ($(document).height() - 200)
        @queueNextPage()
    else
      @nextTicks = 0

      if $(window).scrollTop() == 0
        @queuePrevPage()

    Twine.refresh()

  queuePrevPage: ->

  queueNextPage: ->
    @nextTicks += 1
    if @nextTicks > NUM_TICKS
      $(".js-next-page")[0]?.click()

  nextProgressCssWidth: =>
    percentage = (@nextTicks / NUM_TICKS) * 100
    "width: #{percentage}%"

  loadNextPage: ->
    $(".js-next-page")[0].click()
    window.scrollTo(0,0)

  loadPrevPage: ->
    $(".js-prev-page")[0].click()
    window.scrollTo(0,0)
  #
  # loadNextPage: ->
  #   return if @locked
  #   @locked = true
  #
  #   nextPage = @currentPage + 1
  #
  #   uri = URI().setQuery("page", nextPage)
  #
  #   NProgress.start()
  #
  #   $.ajax
  #     url: uri.toString()
  #   .done (response) =>
  #     $response = $(response)
  #     $moreTiles = $response.find(".tile-list").children()
  #
  #     @currentPage = nextPage
  #     $(".tile-list").append($moreTiles)
  #   .always =>
  #     @locked = false
  #     NProgress.done()
