μv (aka muv aka muvee)
===

μv: (pronounced: mew-vee, somewhat like "movie")

[Join in the developer chat](https://chat.echoplex.us/muv)

Netflix, for your home.
WIP

To install and use
---
1. `sudo apt-get install postgresql-9.3 libpq-dev libav-tools nodejs nginx imagemagick libffi-dev libphash0 libphash0-dev`
2. `sudo ln -s /usr/bin/nodejs /usr/bin/node` because Ubuntu installs node in a different place than most
3. `bundle install`
4. `bundle exec database:create` (or manually create a postgres role and set up your `database.yml`)
5. Make sure your `database.yml` is correct!
8. `bundle exec rake nginx:restart` to start up nginx (disregard any error messages)
9. `bundle exec foreman start`
9. Visit http://localhost:8080
10. Visit http://localhost:8080/videos/generate.json and wait!

Dependencies (and tested with):
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
