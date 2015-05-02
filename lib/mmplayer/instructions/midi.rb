module MMPlayer

  module Instructions

    # Instructions for dealing with MIDI
    module MIDI

      # Set the MIDI channel to receive messages on
      # @param [Fixnum, nil] num The channel number 0-15 or nil for all
      def receive_channel(num)
        @midi.channel = num
      end
      alias_method :rx_channel, :receive_channel

      # Assign a callback for a given MIDI system command
      # @param [String, Symbol] note A MIDI system command eg :start, :continue, :stop
      # @param [Proc] callback The callback to execute when a matching message is received
      # @return [Hash]
      def on_system(command, &callback)
        @midi.add_system_callback(command, &callback)
      end
      alias_method :system, :on_system

      # Assign a callback for a given MIDI note
      # @param [Fixnum, String] note A MIDI note eg 64 "F4" or nil for all
      # @param [Proc] callback The callback to execute when a matching message is received
      # @return [Hash]
      def on_note(note = nil, &callback)
        @midi.add_note_callback(note, &callback)
      end
      alias_method :note, :on_note

      # Assign a callback for the given MIDI control change
      # @param [Fixnum] index The MIDI control change index to assign the callback for or nil for all
      # @param [Proc] callback The callback to execute when a matching message is received
      # @return [Hash]
      def on_cc(index = nil, &callback)
        @midi.add_cc_callback(index, &callback)
      end
      alias_method :cc, :on_cc

    end

  end

end
