class Muvee.HueController

  constructor: (@node, @opts) ->
    @videoEl = $(@node).find("video")[0]
    @lightPref = localStorage.getItem("hue-preference") || "off"

    $(@videoEl).on "play.HueController", =>
      @dimLights()

    $(@videoEl).on "timeupdate.VideoPlayer", _.throttle =>
      @setHueDynamically()
    , 5000

    $(@videoEl).on "pause.HueController", =>
      @brightenLights()

    Page.onReplace @node, @destructor

  destructor: ->
    $(document).off(".HueController")

  setBrightnessOnly: ->
    @lightPref = "brightness"
    @savePreference()

  setBrightnessAndHue: ->
    @lightPref = "hue"
    @savePreference()

  setOff: ->
    @lightPref = "off"
    @savePreference()

  cycleMode: ->
    if @lightPref == "off"
      @setBrightnessOnly()
    else if @lightPref == "brightness"
      @setBrightnessAndHue()
    else
      @setOff()

  brightenLights: ->
    return unless @shouldManageBrightness()
    $.post(@opts.brightenPath)

  dimLights: ->
    return unless @shouldManageBrightness()
    $.post(@opts.dimPath)

  setHue: (rgbs) ->
    return unless @shouldManageHue()
    $.post(@opts.setPath, {colors: rgbs})

  shouldManageHue: ->
    @lightPref == "hue"

  shouldManageBrightness: ->
    @lightPref == "hue" || @lightPref == "brightness"

  savePreference: ->
    localStorage.setItem("hue-preference", @lightPref)

  getSamplingContext: ->
    return @samplerContext if @samplerContext
    samplerCanvas = document.getElementById("pixel-sampler")
    @samplerContext = samplerCanvas.getContext('2d')
    @samplerContext

  sampleVideo: ->
    return if @videoEl.paused || @videoEl.ended
    ctx = @getSamplingContext()
    ctx.drawImage(video,0,0,8,8)
    pix = ctx.getImageData(0,0,8,8).data
    rgbs = []
    i = 0
    while i < pix.length
      rgb = {r: pix[i], g: pix[i+1], b: pix[i+2]}
      rgbs.push rgb
      i += 4

    rgbs

  setHueDynamically: ->
    return unless @shouldManageHue()
    rgbs = @sampleVideo()
    @setHue(rgbs) if rgbs
