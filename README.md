# mmplayer

Control MPlayer with MIDI

## Usage

```ruby
require "mmplayer"

@input = UniMIDI::Input.gets

@player = MMPlayer.new(@input, :flags => "-fs") do

  channel 0

  note(1) { play("1.mov") }
  note(2) { play("2.mov") }

  cc(1) { |value| volume(:set, value) }
  cc(20) { |value| seek(percent(value), :percent) }

end

@player.start

```