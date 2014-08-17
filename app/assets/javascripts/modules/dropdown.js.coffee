$(document).on "click", ".dropdown-trigger", (ev) ->
  $(ev.currentTarget).parents(".dropdown").find(".dropdown-options").toggle()
