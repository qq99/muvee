μv (aka muv aka muvee)
===

μv: (pronounced: mew-vee, somewhat like "movie")

This project is something like Netflix, but run on a server in your own home.  It aims to be an open source alternative to Plex. It can attempt to reach out to the Internet to find sources for media that you legally own, but do not yet possess backups of.

At the moment, it's a media manager that presents a web UI reminiscent of Netflix.  It grabs metadata, posters, and fanart, and displays it all in a nice to consume format from any device in your household.

I started it because I wanted to view my media on my PS4.  Since then, PS4 added DLNA and I've modified muvee so much that this project won't even work with the PS4 browser (alas, it can't handle flexbox).  It works quite nicely on a Mac Mini connected to your TV.

[Recent pictures](http://imgur.com/a/DwAuU)

[YouTube video of a recent revision](https://www.youtube.com/watch?v=1tevKG6u1qM&html5=1)

[Pictures of the project in very early stages](http://imgur.com/a/2wBvh)

Pictures
---
![](http://i.imgur.com/hF34OQD.jpg)
_Movies index_

![](http://i.imgur.com/KYXjST4.jpg)
_Detailed movie view page, when movie is sourced (you have a copy)_

![](http://i.imgur.com/HXxaBe5.jpg)
_Detailed movie view page, when movie is not yet sourced (you don't have a copy)_

![](http://i.imgur.com/CofpprC.jpg)
_Attempting to find copies_

![](http://i.imgur.com/DyqHsKO.jpg)
_Discover movies, or search for them on the net_

![](http://i.imgur.com/SjCLDzW.jpg)
_Movies index while downloading, blue progress bar appears_

![](http://i.imgur.com/guLrAhy.png)
_Detailed movie page while downloading, blue progress bar appears_

![](http://i.imgur.com/e8WO4k4.jpg)
_Pressing the `t` key on any index page lets you quickly search the movies muvee knows about_

![](http://i.imgur.com/D6QYoF4.jpg)
_Series index page_

![](http://i.imgur.com/uoTOnwQ.jpg)
_Series details page, green bars represent your watching progress_

![](http://i.imgur.com/x7wyRSz.jpg)
_Series details page, trying to find a source_

![](http://i.imgur.com/8s1RNqD.jpg)
_Series details page while downloading, blue progress bar appears_

![](http://i.imgur.com/dddCOoB.jpg)
_On deck, your latest unwatched episodes_

![](http://i.imgur.com/JvXkr5e.jpg)
_Viewing more details about a particular episode in a season_

![](http://i.imgur.com/FAetn4G.png)
_Settings and configuration_

![](http://i.imgur.com/jjRnc1E.png)
_Status page, any progress bars of currently executing jobs_

![](http://i.imgur.com/KO5dUKM.jpg)
_The player itself_

To install and use on Linux
---
0. Install the Transmission bittorrent client, and enable web access (restricting it to 127.0.0.1 is fine). This is required to run muvee atm until I code around errors thrown when it is not running.  Your remote settings should look like this for muvee to interact with Transmission.  You can set your other client settings however you like.
![](http://imgur.com/wjzDzVI.jpg)
1. `sudo apt-get install postgresql-9.3 libpq-dev libav-tools nginx redis` or if on OSX, `brew install postgresql redis nginx libav`
2. `bundle install`
3. `bundle exec rake database:create` (or manually create a postgres role and set up your `database.yml`, e.g., `psql -c "create role muvee with createdb login password 'password1'"`)
4. `bundle exec rake db:create` (different than above!) then `bundle exec rake db:migrate`
5. If the last step failed to migrate, try `bundle exec rake db:reset`
6. Make sure your `database.yml` is correct!
7. `bundle exec rake nginx:restart` to start up nginx with the custom configuration required.  It will attempt to kill any instances of nginx the user can access (but should not be a problem if you're not doing this as root).  Disregard any error messages regarding logs.
8. `bundle exec foreman start` (or if you want to run rails separately from sidekiq, `bundle exec rails s` and `bundle exec sidekiq`)
9. Visit http://localhost:8080
10. Set up your media paths
11. If all is well, you can then click the gear and "Scan for new media".  Wait, and media items will begin to appear as you refresh
12. Set your TV to `Just scan` mode or similar (see your TV's documentation) so that edges aren't clipped

Integration with Hue lights
---

`muvee` can control your lights!  Your lights will brighten when playback is paused/stopped, and dim when playback is starts.  Additionally, there is a setting to have it sample the picture periodically to change the hue to approximate the colours of the scene.

If you haven't played with the Ruby `hue` gem yet, you'll need to create a group with the API (easiest in `bundle exec rails console`):

```ruby
client = Hue::Client.new
light = client.lights.first
light.on! # or light.off!, you will need to hit the button on your bridge, then try these commands again until it works
group = client.group
group.lights = client.lights # or a specific subset of the lights you want to control
group.name = "Default Group"
group.create!
```

At the moment, `muvee` uses `client.groups.first` as the set of lights it will dim and brighten throughout playback.  This will hopefully change as the project grows and matures to be configurable from within the UI.

Dependencies (and tested with):
---

- transmission 2.84
- postgresql-9.3 libpq-dev
- ruby 2.2.2
- redis (for sidekiq)
  - sudo apt-get install redis
- libav-tools
  - avconv / ffmpeg (req `avconv` command on your path)
    - avconv version 9.14-6:9.14-0ubuntu0.14.04.1
    - ffmpeg version 2.7.6-0ubuntu0.15.10.1
  - avprobe / ffprobe (req `avprobe` command on your path)
    - avprobe version 9.14-6:9.14-0ubuntu0.14.04.1
    - ffprobe version 2.7.6-0ubuntu0.15.10.1
- nginx version (req `nginx` command available on your path):
  - nginx/1.9.3 (Ubuntu)
  - nginx/1.4.6 (Ubuntu)

Deprecated dependencies:
- ImageMagick 6.7.7-10 2014-03-06 Q16 (**deprecated** for now)
- libffi-dev libphash0 libphash0-dev (for determining 3D-ness of movies; **deprecated**)
  - `sudo apt-get install libffi-dev libphash0 libphash0-dev`

Hotkeys
---
- `spacebar`: pause
- `left arrow`: Jump back in time
- `right arrow`: Jump forward in time
- `up arrow`: Increase volume
- `down arrow`: Decrease volume
- `t` (on series/movie index pages): Bring up a quick search bar

Definitions of terms
---
- `sbs`: side-by-side (3D)
- `tab`: top-and-bottom (3D)
