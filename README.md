μv (aka muv aka muvee)
===

μv: (pronounced: mew-vee, somewhat like "movie")

[Join in the developer chat](https://chat.echoplex.us/muv)

Netflix, for your home.
WIP

Requires (and tested with):
---

- postgresql-9.3 libpq-dev
- ruby 2.1.2+
- redis (for sidekiq)
  - sudo apt-get install redis
- libav-tools
  - avconv version 9.14-6:9.14-0ubuntu0.14.04.1
  - avprobe version 9.14-6:9.14-0ubuntu0.14.04.1
- node.js 0.10.25+
- nginx version: nginx/1.4.6 (Ubuntu)
  - globally available on your path
- ImageMagick 6.7.7-10 2014-03-06 Q16
- libffi-dev libphash0 libphash0-dev (for determining 3D-ness of movies)
  - `sudo apt-get install libffi-dev libphash0 libphash0-dev`

Definitions
---
`sbs`: side-by-side (3D)
`tab`: top-and-bottom (3D)
