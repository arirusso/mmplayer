module MMPlayer

  class Context

    include Numbers
    extend Forwardable

    def_delegators :@midi, :cc, :note
    def_delegators :@player, :active?, :play, :repeat

    def initialize(midi_input, options = {}, &block)
      @midi = MIDI.new(midi_input)
      @player = Player.new(:flags => options[:flags])
      instance_eval(&block) if block_given?
    end

    def channel(num)
      @midi.channel = num
    end

    def start(options = {})
      @midi.start
      loop until @player.active?
      while @player.active?
        sleep(0.005)
        #puts @player.progress
      end
    end

    def method_missing(method, *args, &block)
      if @player.respond_to?(method)
        @player.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || @player.respond_to?(method)
    end

  end

end
