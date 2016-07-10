Muvee.cable.subscriptions.create "GeneralProgressReporterChannel",
  received: (data) ->
    namespace = data.namespace
    evt = new CustomEvent(
      "muvee:progress_reporter:#{namespace}",
      {'detail': data}
    )
    document.dispatchEvent(evt)
