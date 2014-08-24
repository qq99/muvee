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
  document.getElementById("global-options").hide()
  operation = $.ajax({
    url: "/videos/generate.json"
  })
  operation.done (data, textStatus, jqXHR) ->
    $(".new-tv").text(data.new_tv_shows.length)
    $(".failed-tv").text(data.failed_tv_shows.length)
    $(".new-movies").text(data.new_movies.length)
    $(".failed-movies").text(data.failed_movies.length)
    document.getElementById("scan-results").show()

showNavOnMousemove = (ev) ->
  if ev.screenY < 300
    showNav()
  else
    hideNav()

$(document).on "mousemove", _.throttle(showNavOnMousemove, 100)
$(document).on "click", "#showGlobalOptions", (ev) ->
  ev.preventDefault()
  document.getElementById("global-options").show()

$ ->
  hideNav()
