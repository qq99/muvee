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


showNavOnMousemove = (ev) ->
  if ev.pageY < 300
    showNav()
  else
    hideNav()

$(document).on "mousemove", _.throttle(showNavOnMousemove, 100)

$ ->
  hideNav()
