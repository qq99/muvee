locked = false
hidingNav = -1
hideNav = ->
  return if locked
  clearTimeout hidingNav
  locked = true
  hidingNav = setTimeout ->
    $(".main-navigation").addClass("hidden")
    navRequestedShown = false
    locked = false
  , 5000

showNav = ->
  clearTimeout hidingNav
  locked = true
  $(".main-navigation").removeClass("hidden")
  locked = false

$(document).on "focus", ".main-navigation", showNav
$(document).on "blur", ".main-navigation", hideNav

window.rescanLibrary = (ev) ->
  operation = $.ajax({
    url: "/videos/generate.json"
  })

window.reanalyzeLibrary = (ev) ->
  operation = $.ajax({
    url: "/videos/reanalyze.json"
  })

showNavOnMousemove = (ev) ->
  if ev.screenY < 300
    showNav()
  else
    hideNav()

$(document).on "mousemove", _.throttle(showNavOnMousemove, 100)
$(document).on "click", "#showGlobalOptions", (ev) ->
  ev.preventDefault()
  $("#global-options").addClass("show")

$(document).on "click", ".js-close-modal", ->
  $(".modal").removeClass("show")

$ ->
  hideNav()
