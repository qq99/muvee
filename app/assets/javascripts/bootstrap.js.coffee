$(document).on 'page:fetch', -> NProgress.start()
$(document).on 'page:change', -> NProgress.done()
$(document).on 'page:restore', -> NProgress.remove()

$ ->
  console.log "Boostrapping"
  $.ajaxSetup
    headers:
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
