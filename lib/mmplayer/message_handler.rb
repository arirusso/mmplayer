module MMPlayer

  # Directs what should happen when messages are received
  class MessageHandler

    attr_reader :callback

    def initialize
      @callback = {
        :cc => {},
        :note => {},
        :system => {}
      }
    end

    # Add a callback for a given MIDI system message type
    # @param [Symbol] type The MIDI message type (eg :note, :cc)
    # @param [String, Symbol] key
    # @param [Proc] callback The callback to execute when the given MIDI command is received
    # @return [Hash]
    def add_callback(type, key, &callback)
      @callback[type][key] = callback
      @callback[type]
    end

    # Process a message for the given channel
    # @param [Fixnum, nil] channel
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def process(channel, message)
      case message
      when MIDIMessage::SystemRealtime then system_message(message)
      else
        channel_message(channel, message)
      end
    end

    # Find and call a note received callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def note_message(message)
      unless (callback = @callback[:note][message.note] || @callback[:note][message.name]).nil?
        callback.call(message.velocity)
        true
      end
    end

    # Find and call a cc received callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def cc_message(message)
      unless (callback = @callback[:cc][message.index] || @callback[:cc][message.name]).nil?
        callback.call(message.value)
        true
      end
    end

    # Find and call a system message callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def system_message(message)
      name = message.name.downcase.to_sym
      unless (callback = @callback[:system][name]).nil?
        callback.call
        true
      end
    end

    # Find and call a channel message callback if it exists for the given message and channel
    # @param [Fixnum, nil] channel
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def channel_message(channel, message)
      if channel.nil? || message.channel == channel
        case message
        when MIDIMessage::NoteOn then note_message(message)
        when MIDIMessage::ControlChange then cc_message(message)
        end
      end
    end

  end

end
