onError = (jqXHR, textStatus, errorThrown) ->
  $(".modal.error .error-text").text(JSON.parse(jqXHR.responseText).status)
  $(".modal.error").addClass("show")

window.rescanLibrary = (ev) ->
  operation = $.ajax({
    url: "/videos/generate.json"
  })
  operation.fail onError

window.reanalyzeLibrary = (ev) ->
  operation = $.ajax({
    url: "/videos/reanalyze.json"
  })
  operation.fail onError

window.redownloadImages = (ev) ->
  operation = $.ajax({
    url: "/videos/redownload.json"
  })
  operation.fail onError

window.redownloadMissingImages = (ev) ->
  operation = $.ajax({
    url: "/videos/redownload_missing.json"
  })
  operation.fail onError

$(document).on "click", ".js-close-modal", ->
  $(".modal").removeClass("show")

$(document).on "click", "[data-modal]", (ev) ->
  ev.preventDefault()
  modalId = $(ev.currentTarget).data("modal")
  $("##{modalId}").addClass("show")
