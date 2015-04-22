module MMPlayer

  module Instructions

    # Instructions for dealing with MIDI
    module MIDI

      # Set the MIDI channel to receive messages on
      # @param [Fixnum] num The channel number 0-15
      def receive_channel(num)
        @midi.channel = num
      end
      alias_method :rx_channel, :receive_channel

      # Assign a callback for a given MIDI note
      # @param [Fixnum, String] note A MIDI note eg 64 "F4"
      # @param [Proc] callback The callback to execute when a matching message is received
      # @return [Hash]
      def on_note(note, &callback)
        @midi.add_note_callback(note, &callback)
      end
      alias_method :note, :on_note

      # Assign a callback for the given MIDI control change
      # @param [Fixnum] index The MIDI control change index to assign the callback for
      # @param [Proc] callback The callback to execute when a matching message is received
      # @return [Hash]
      def on_cc(index, &callback)
        @midi.add_cc_callback(index, &callback)
      end
      alias_method :cc, :on_cc

    end

  end

end
