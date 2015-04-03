class Muvee.FixedSearch

  INPUT_SELECTOR = '.fixed-search__input'

  constructor: (node) ->
    @visible = false
    @bindGlobalListener()

    $(".fixed-search__input").on "keydown.FixedSearch", (ev) =>
      @hide() if ev.keyCode == 27 || ev.keyCode == 13 # esc

  bindGlobalListener: ->
    @globalListener = $(document).on 'keydown.FixedSearch', (ev) =>
      if ev.keyCode == 84 # t
        @show()
        Twine.refresh()
        ev.preventDefault()

  clearGlobalListener: ->
    console.log 'Manual unbind'
    @globalListener.off()

  clear: ->
    $(INPUT_SELECTOR).val('')

  show: ->
    @clearGlobalListener()
    @clear()
    @visible = true
    $(INPUT_SELECTOR).focus()

  hide: ->
    @visible = false
    @bindGlobalListener()
    Twine.refresh()
