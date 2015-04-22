module MMPlayer

  module Helper

    # Number conversion
    module Numbers

      # Converts a percentage to a 7-bit int value eg 50 -> 0x40
      # @param [Fixnum] num
      # @return [Fixnum]
      def to_midi_value(num)
        Scale.transform(num).from(0..100).to(0..127.0).round
      end

      # Converts a MIDI 7-bit int value to a percentage eg 0x40 -> 50
      # @param [Fixnum] num
      # @return [Fixnum]
      def to_percent(num)
        Scale.transform(num).from(0..127).to(0..100.0).round
      end

    end

  end

end
