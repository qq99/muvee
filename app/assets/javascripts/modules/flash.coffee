class Muvee.Flash

  constructor: (@node) ->
    @$node = $(@node)

    return unless @node.classList.contains("js-has-flash")
    _.defer @show
    setTimeout(@hide, 3000)

  show: =>
    @$node.addClass("is-active")

  hide: =>
    @$node.removeClass("is-active")
