require('coffee-script')
fs = require("fs")
async = require("async")
path = require("path")
child_process = require('child_process')
express = require('express');
app = express();


app.get '/', (req, res) ->
  res.send('hello world')

live_transcoder = null

app.get '/stream', (req, res) ->

  filepath = '/foo/bar/baz.mp4'

  if live_transcoder == null
    live_transcoder = child_process.spawn('ffmpeg', [
      '-i', filepath,
      '-movflags', 'empty_moov+faststart',
      '-c:v', 'libx264',
      # '-c:v', 'copy',
      '-crf', '20',
      '-preset', 'ultrafast',
      '-pix_fmt', 'yuv420p',
      # '-vsync', '1',
      # '-r', '25',
      # '-c:a', 'aac',
      # '-c:a', 'copy',
      '-strict', '-2',
      # '-b:a', '16k',
      # '-ar', '16000',
      # '-ac', '1',
      '-f', 'mp4',
      '-' # output to stdout
    ], {detached: false})

    live_transcoder.stderr.on "data", (data) ->
      console.log data.toString()

    live_transcoder.on "exit", (code) ->
      console.log "Transcoder terminated with code #{code}"

    live_transcoder.on "error", (e) ->
      console.log "Transcoder error #{e}"

  range = req.headers.range
  stat = fs.statSync(filepath)
  return res.send("Not a file", 500) if !stat.isFile()

  info =
    path: filepath
    start: 0
    end: stat.size - 1
    size: stat.size
    modified: stat.mtime
    rangeRequest: false

  # see https://github.com/meloncholy/vid-streamer/blob/master/index.js

  if range && (range = range.match(/bytes=(.+)-(.+)?/)) != null
    # Check range contains numbers and they fit in the file.
    # Make sure info.start & info.end are numbers (not strings) or stream.pipe errors out if start > 0.
    r1 = parseFloat(range[1])
    r2 = parseFloat(range[2])
    if r1 >= 0 && r1 < info.end
      info.start = r1
    if r2 > info.start && r2 <= info.end
      info.end = r2
    info.rangeRequest = true

  info.length = info.end - info.start + 1

  header =
    "Cache-Control": "public; max-age=0"
    "Connection": "keep-alive"
    # "Content-Type": info.mime
    "Content-Disposition": "inline; filename=test.mp4;"
    # "Pragma": "public"
    "Last-Modified": info.modified.toUTCString()
    "Content-Transfer-Encoding": "binary",
    "Accept-Ranges": "bytes",
    "Content-Type": "video/mp4"
    # "Content-Length": info.length

  code = 200

  # if info.rangeRequest # Partial http respons
  #   code = 206
  #   header["Status"] = "206 Partial Content"
  #   header["Accept-Ranges"] = "bytes"
  #   header["Content-Range"] = "bytes #{info.start}-#{info.end}/#{info.size}"

  res.writeHead(code, header)

  # stream = fs.createReadStream filepath,
  #   flags: "r"
  #   start: info.start
  #   end: info.end
  #
  # stream.pipe(res)
  live_transcoder.stdout.pipe(res, { end: false });
  # live_transcoder.stdout.on "data", ->
  #   console.log 'data'
  # console.log 'test'

  # return true


app.listen 7070
