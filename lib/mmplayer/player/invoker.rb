module MMPlayer

  module Player

    # Invoke MPlayer
    class Invoker

      attr_reader :player, :thread

      # @param [Hash] options
      # @option options [String] :flags MPlayer command-line flags to use on startup
      def initialize(options = {})
        @flags = "-fixed-vo -idle"
        @flags += " #{options[:flags]}" unless options[:flags].nil?
        @player.nil?
        @thread = nil
      end

      def destroy
        @thread.kill unless @thread.nil?
      end

      # Ensure that the MPlayer process is invoked
      # @param [String] file The media file to invoke MPlayer with
      # @param [MMplayer::Player::State] state
      # @return [MPlayer::Slave]
      def ensure_invoked(file, state)
        if @player.nil? && @thread.nil?
          @thread = Thread.new do
            begin
              @player = MPlayer::Slave.new(file, :options => @flags)
              state.handle_start
            rescue Exception => exception
              Thread.main.raise(exception)
            end
          end
          @thread.abort_on_exception
        end
        @player
      end

    end

  end
end
