module MMPlayer

  module Player

    class State

      attr_accessor :eof, :pause, :play
      alias_method :eof?, :eof
      alias_method :pause?, :pause
      alias_method :paused?, :pause
      alias_method :play?, :play
      alias_method :playing?, :play

      def initialize
        @eof = false
        @play = false
        @pause = false
      end

      def toggle_pause
        @pause = !@pause
      end

      def progressing?
        @play && !@pause
      end

      def eof_reached?
        @play && !@eof && !@pause
      end

      def handle_eof
        @eof = true
        @play = false
      end

      def handle_start
        @play = true
        @eof = false
      end

    end
  end
end
