onError = (jqXHR, textStatus, errorThrown) ->
  $(".modal.error .error-text").text(JSON.parse(jqXHR.responseText).status)
  $(".modal.error").addClass("show")

$(document).on "click", ".js-close-modal", ->
  $(".modal").removeClass("show")

$(document).on "click", "[data-modal]", (ev) ->
  ev.preventDefault()
  modalId = $(ev.currentTarget).data("modal")
  $("##{modalId}").addClass("show")


$ ->
  socket = new Muvee.MuveeSocket()
