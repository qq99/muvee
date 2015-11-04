class Muvee.FixedSearch

  INPUT_SELECTOR = '.fixed-search__input'

  constructor: (@node) ->
    @bindGlobalListener()

    $(".fixed-search__input").on "keydown.FixedSearch", (ev) =>
      @hide() if ev.keyCode == 27 || ev.keyCode == 13 # esc

  bindGlobalListener: ->
    $(document).on 'keydown.FixedSearch', (ev) =>
      if ev.keyCode == 84 # t
        return if ev.target.tagName == 'INPUT'
        @show()
        ev.preventDefault()

  clearGlobalListener: ->
    $(document).off(".FixedSearch")

  clear: ->
    $(INPUT_SELECTOR).val('')

  toggle: ->
    if @showing
      @hide()
    else
      @show()
    false

  show: ->
    @showing = true
    $(@node).removeClass('hide')
    @clearGlobalListener()
    @clear()
    setTimeout =>
      $(@node).addClass('is-active')
      $(INPUT_SELECTOR).focus()
    , 250

  hide: =>
    @showing = false
    @bindGlobalListener()
    $(@node).removeClass('is-active')
    setTimeout =>
      $(@node).addClass('hide')
    , 250
