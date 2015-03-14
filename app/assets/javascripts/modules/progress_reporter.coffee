class Muvee.ProgressReporter

  # nice test:  evt = new CustomEvent('muvee:progress_reporter:VideoCreationService', {detail: {status: 'scanning', substatus: '/foo/bar/baz.mp4', current: 50, max: 2568}}); document.dispatchEvent(evt)

  constructor: (@node, namespace) ->
    @visible = false

    @listener = document.addEventListener "muvee:progress_reporter:#{namespace}", @update.bind(this)

    Page.onReplace(@node, @destructor.bind(this))

  destructor: ->
    document.removeEventListener(@listener)

  isShown: ->
    @visible

  isHidden: ->
    !@visible

  progress: ->
    return 0 if !@current? && !@max?

    (@current / (@max * 1.0)) * 100

  progressPercent: ->
    progress = @progress() || 0
    "#{parseInt(progress, 10)}%"

  progressCssWidth: ->
    "width: #{@progress()}%"

  # e.g.,:
  # {status: "scanning", current: i, max: creation_size, substatus: filepath}
  # {status: "complete", current: creation_size, max: creation_size, substatus: "Done!"}
  update: (opts) ->
    _.extend(this, opts.detail)

    if @status == 'complete'
      @visible = false
    else
      @visible = true

    Twine.refresh()
