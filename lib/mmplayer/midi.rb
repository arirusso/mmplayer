module MMPlayer

  class MIDI

    attr_accessor :channel
    attr_reader :config, :listener

    def initialize(input)
      @channel = nil
      @config = {
        :note => {},
        :cc => {}
      }
      @listener = MIDIEye::Listener.new(input)
    end

    def note(num, &callback)
      @config[:note][num] = callback
    end

    def cc(num, &callback)
      @config[:cc][num] = callback
    end

    def start(options = {})
      @listener.on_message(:channel => @channel, :class => MIDIMessage::NoteOn) do |event|
        message = event[:message]
        @config[:note][message.note].call(message.velocity)
      end
      @listener.on_message(:channel => @channel, :class => MIDIMessage::ControlChange) do |event|
        message = event[:message]
        @config[:cc][message.note].call(message.value)
      end
      @listener.start(:background => options[:background])
    end

  end

end
