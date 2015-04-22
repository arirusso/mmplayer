module MMPlayer

  class MIDI

    attr_accessor :channel
    attr_reader :config, :listener

    # @param [UniMIDI::Input] input
    def initialize(input)
      @channel = nil
      @config = {
        :note => {},
        :cc => {}
      }
      @listener = MIDIEye::Listener.new(input)
    end

    # Add a callback for a given MIDI note
    # @param [Fixnum, String] note The MIDI note to add a callback for eg 64 "E4"
    # @param [Proc] callback The callback to execute when the given MIDI note is received
    # @return [Hash]
    def add_note_callback(note, &callback)
      @config[:note][note] = callback
      @config[:note]
    end

    # Add a callback for a given MIDI control change
    # @param [Fixnum] index The MIDI control change index to add a callback for eg 10
    # @param [Proc] callback The callback to execute when the given MIDI control change is received
    # @return [Hash]
    def add_cc_callback(index, &callback)
      @config[:cc][index] = callback
      @config[:cc]
    end

    # Stop the MIDI listener
    # @return [Boolean]
    def stop
      @listener.stop
    end

    # Start the MIDI listener
    # @return [Boolean]
    def start
      @listener.on_message(:channel => @channel, :class => MIDIMessage::NoteOn) do |event|
        message = event[:message]
        unless (callback = @config[:note][message.note] || @config[:note][message.name]).nil?
          callback.call(message.velocity)
        end
      end
      @listener.on_message(:channel => @channel, :class => MIDIMessage::ControlChange) do |event|
        message = event[:message]
        unless (callback = @config[:cc][message.index] || @config[:cc][message.name]).nil?
          callback.call(message.value)
        end
      end
      @listener.start(:background => true)
      true
    end

  end

end
