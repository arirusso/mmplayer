module MMPlayer

  module Player

    # Handle sending MPlayer messages
    class Messenger

      FREQUENCY_LIMIT = 0.1 # Throttle messages to 1 per this number seconds

      def initialize
        @messages = []
      end

      # Send mplayer a message asynch
      # @return [Hash, nil]
      def send_message(&block)
        timestamp = Time.now.to_f
        # Throttled messages are disregarded
        if @messages.empty? || !throttle?(timestamp, @messages.last[:timestamp])
          thread = Thread.new do
            begin
              yield
            rescue Exception => exception
              Thread.main.raise(exception)
            end
          end
          thread.abort_on_exception = true
          record_message(thread, timestamp)
        end
      end

      private

      # Should adding a message be throttled for the given timestamp?
      # @param [Float] timestamp
      # @param [Float] last_timestamp
      # @return [Boolean]
      def throttle?(timestamp, last_timestamp)
        timestamp - last_timestamp <= FREQUENCY_LIMIT
      end

      # Record that a message has been sent
      # @param [Thread] thread
      # @param [Float] timestamp
      # @return [Hash]
      def record_message(thread, timestamp)
        message = {
          :thread => thread,
          :timestamp => timestamp
        }
        @messages << message
        message
      end

    end
  end
end
