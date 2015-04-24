# mmplayer

![image](http://i.imgur.com/Te9nymX.png)

Control [MPlayer](http://en.wikipedia.org/wiki/MPlayer) with MIDI

## Install

MPlayer needs to be installed.  This can usually be accomplished with a package manager eg `brew install mplayer` depending on what OS you're using

This project itself can be installed as a Ruby Gem using 

`gem install mmplayer` 

Or if you're using Bundler, add this to your Gemfile

`gem "mmplayer"`

## Usage

MMplayer provides a Ruby DSL to define interactions between MIDI input and MPlayer

```ruby
require "mmplayer"

@input = UniMIDI::Input.gets

@player = MMPlayer.new(@input, :mplayer_flags => "-fs") do

  rx_channel 0

  system(:start) { play("1.mov") }
  
  note(1) { play("2.mov") }
  note("C2") { play("3.mov") }

  cc(1) { |value| volume(:set, value) }
  cc(20) { |value| seek(to_percent(value), :percent) }

end

@player.start

```

See a full annotated breakdown of this example [here](https://github.com/arirusso/mmplayer/blob/master/examples/simple.rb)

See [the MPlayer Man Page](http://www.mplayerhq.hu/DOCS/man/en/mplayer.1.html#GENERAL OPTIONS) for a full list of startup flags

All MPlayer runtime commands enabled by the [mplayer-ruby](https://rubygems.org/gems/mplayer-ruby) project are available here too. (eg `seek` and `volume` in the example above)

See [the RDOC for mplayer-ruby](http://mplayer-ruby.rubyforge.org/mplayer-ruby/index.html) for a full list of runtime commands

##Author

* [Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>

##License

Apache 2.0, See LICENSE file

Copyright (c) 2015 [Ari Russo](http://arirusso.com)
