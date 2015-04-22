module MMPlayer

  module MIDI

    def channel(num)
      @channel = num
    end

    def note(num, &callback)
      midi_config[:note][num] = callback
    end

    def cc(num, &callback)
      midi_config[:cc][num] = callback
    end

    private

    def midi_config
      @config ||= {
        :note => {},
        :cc => {}
      }
    end

    def start_midi
      listener.on_message(:channel => @channel, :class => MIDIMessage::NoteOn) do |event|
        message = event[:message]
        midi_config[:note][message.note].call(message.note)
      end
      listener.on_message(:channel => @channel, :class => MIDIMessage::ControlChange) do |event|
        message = event[:message]
        @midi_options[:cc][message.note].call(message.value)
      end
      listener.start(:background => true)
    end

    def listener
      @listener ||= MIDIEye::Listener.new(@midi_input)
    end

  end

end
