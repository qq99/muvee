μv (aka muv aka muvee)
===

μv: (pronounced: mew-vee, somewhat like "movie")

[Join in the developer chat](https://chat.echoplex.us/muv)

This project is something like Netflix, but run on a server in your own home.  It aims to be an open source alternative to Plex

At the moment, it's a media manager that presents a web UI reminiscent of Netflix.  It grabs metadata, posters, and fanart, and displays it all in a nice to consume format from any device in your household.

I started it because I wanted to view my media on my PS4 (but as of late, I've just been using Chrome on a mac mini connected to my TV)

WIP

[Pictures!](http://imgur.com/a/2wBvh)

To install and use
---
1. `sudo apt-get install postgresql-9.3 libpq-dev libav-tools nodejs nginx imagemagick libffi-dev libphash0 libphash0-dev redis`
2. `sudo ln -s /usr/bin/nodejs /usr/bin/node` because Ubuntu installs node in a different place than most
3. `bundle install`
4. `bundle exec database:create` (or manually create a postgres role and set up your `database.yml`)
5. Make sure your `database.yml` is correct!
8. `bundle exec rake nginx:restart` to start up nginx with the custom configuration required.  It will attempt to kill any instances of nginx the user can access (but should not be a problem if you're not doing this as root).  Disregard any error messages regarding logs.
9. `bundle exec foreman start`
10. Visit http://localhost:8080
11. Set up your media paths
12. If all is well, you can then click the gear and "Scan for new media".  Wait, and media items will begin to appear as you refresh
13. Set your TV to `Just scan` mode or similar (see your TV's documentation) so that edges aren't clipped

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

Hotkeys
---
- `spacebar`: pause
- `left arrow`: Jump 5s back in time
- `right arrow`: Jump 5s forward in time
- `-`: Decrease volume by 5%
- `+`: Increase volume by 5%

Definitions of terms
---
- `sbs`: side-by-side (3D)
- `tab`: top-and-bottom (3D)
