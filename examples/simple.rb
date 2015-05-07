#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

# Assign MIDI controls to MPlayer

require "mmplayer"

# Prompt the user to select a MIDI input
@input = UniMIDI::Input.gets

@player = MMPlayer.new(@input, :mplayer_flags => "-fs") do

  # Subscribe to MIDI channel 0 only for received messages.
  # MMPlayer will respond to all channels by default
  rx_channel 0

  # When a MIDI start message is received, start playing the media file 1.mov
  system(:start) { play("1.mov") }

  # When MIDI note 1 is received: a media file 2.mov will begin playing
  note(1) { play("2.mov") }

  # When MIDI note C2 (aka 36) is received: a media file 3.mov will begin playing
  note("C2") { play("3.mov") }

  # When MIDI control change 1 is received, the media volume is set to the received value
  cc(1) { |value| volume(:set, value) }

  # When MIDI control change 20 is received...
  cc(20) do |value|
    percent = to_percent(value) # The received value is converted to percentage eg 0..100
    seek(percent, :percent) # That position in the media file is then moved to
  end

  # In addition to MIDI callbacks, there are callbacks for the player:

  # When a media file ends playing
  eof { puts "finished" }

end

# Start listening for the MIDI messages described above
@player.start

# MPlayer starts when `play` is called for the first time.
# It runs in `fixed-vo` and `idle` mode and stays active until the program exits or `@player.stop` is explicitly called

# The program can also be run in a background thread by passing `@player.start(:background => true)`
