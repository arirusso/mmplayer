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

    # Add a callback for a given MIDI message type
    # @param [Symbol] type The MIDI message type (eg :note, :cc)
    # @param [Fixnum, String] key The ID of the message eg note number/cc index
    # @param [Proc] callback The callback to execute when the given MIDI command is received
    # @return [Hash]
    def add_callback(type, key, &callback)
      @callback[type][key] = callback
      @callback[type]
    end

    # Add a callback for a given MIDI note
    # @param [Symbol] type The MIDI message type (eg :note, :cc)
    # @param [Fixnum, String] note
    # @param [Proc] callback The callback to execute when the given MIDI command is received
    # @return [Hash]
    def add_note_callback(note, &callback)
      note = MIDIMessage::Constant.value(:note, note) if note.kind_of?(String)
      add_callback(:note, note, &callback)
    end

    # Process a message for the given channel
    # @param [Fixnum, nil] channel
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def process(channel, message)
      case message
      when MIDIMessage::SystemCommon, MIDIMessage::SystemRealtime then system_message(message)
      else
        channel_message(channel, message)
      end
    end

    # Find and call a note received callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def note_message(message)
      call_callback(:note, message.note, message.velocity) |
      call_catch_all_callback(:note, message)
    end

    # Find and call a cc received callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def cc_message(message)
      call_callback(:cc, message.index, message.value) |
        call_catch_all_callback(:cc, message)
    end

    # Find and call a system message callback if it exists
    # @param [MIDIMessage] message
    # @return [Boolean, nil]
    def system_message(message)
      name = message.name.downcase.to_sym
      call_callback(:system, name)
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

    private

    # Execute the catch-all callback for the given type if it exists
    # @param [Symbol] type
    # @param [MIDIMessage] message
    # @return [Boolean]
    def call_catch_all_callback(type, message)
      call_callback(type, nil, message)
    end

    # Execute the callback for the given type and key and pass it the given args
    # @param [Symbol] type
    # @param [Object] key
    # @param [*Object] arguments
    # @return [Boolean]
    def call_callback(type, key, *arguments)
      unless (callback = @callback[type][key]).nil?
        callback.call(*arguments)
        true
      end
    end

  end

end
