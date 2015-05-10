class Muvee.Flash

  TRANSITION_END = 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd'

  constructor: (@node) ->
    @$node = $(@node)

    return unless @node.classList.contains("js-has-flash")
    _.defer @show
    setTimeout(@hide, 5000)

  show: =>
    @$node.removeClass("hide")
    setTimeout =>
      @$node.addClass("is-active")
    , 250

  hide: =>
    @$node.one TRANSITION_END, =>
      @$node.addClass("hide")
      @$node.off(TRANSITION_END)
    @$node.removeClass("is-active")
