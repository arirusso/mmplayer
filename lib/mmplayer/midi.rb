module MMPlayer

  # Wrapper for MIDI functionality
  class MIDI

    attr_reader :channel, :config, :listener

    # @param [UniMIDI::Input] input
    # @param [Hash] options
    # @option options [Fixnum] :receive_channel A MIDI channel to subscribe to. By default, responds to all
    def initialize(input, options = {})
      @channel = options[:receive_channel]
      @config = {
        :cc => {},
        :note => {},
        :system => {}
      }
      @listener = MIDIEye::Listener.new(input)
    end

    # Add a callback for a given MIDI system message
    # @param [String, Symbol] command The MIDI system command eg :start, :stop
    # @param [Proc] callback The callback to execute when the given MIDI command is received
    # @return [Hash]
    def add_system_callback(command, &callback)
      @config[:system][command] = callback
      @config[:system]
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

    # Change the subscribed MIDI channel (or nil for all)
    # @param [Fixnum, nil] channel
    # @return [Fixnum, nil]
    def channel=(channel)
      @listener.event.clear
      @channel = channel
      populate_listener if @listener.running?
      @channel
    end

    # Start the MIDI listener
    # @return [Boolean]
    def start
      populate_listener
      @listener.start(:background => true)
      true
    end

    private

    # Populate the MIDI listener events
    def populate_listener
      # Channel messages
      listener_options = {}
      # omni by default
      listener_options[:channel] = @channel unless @channel.nil?
      @listener.on_message(listener_options.merge(:class => MIDIMessage::NoteOn)) do |event|
        message = event[:message]
        unless (callback = @config[:note][message.note] || @config[:note][message.name]).nil?
          callback.call(message.velocity)
        end
      end
      @listener.on_message(listener_options.merge(:class => MIDIMessage::ControlChange)) do |event|
        message = event[:message]
        unless (callback = @config[:cc][message.index] || @config[:cc][message.name]).nil?
          callback.call(message.value)
        end
      end
      # Short messages
      @listener.on_message(:class => MIDIMessage::SystemMessage) do |event|
        message = event[:message]
        name = message.name.downcase.to_sym
        unless (callback = @config[:cc][name]).nil?
          callback.call
        end
      end
      true
    end

  end

end
