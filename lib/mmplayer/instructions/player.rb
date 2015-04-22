module MMPlayer

  module Instructions

    # Instructions dealing with the MPlayer
    module Player

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, :@player, :active?, :play, :progress)
      end

      # Add all of the MPlayer::Slave methods to the context as instructions
      def method_missing(method, *args, &block)
        if @player.mplayer_respond_to?(method)
          @player.mplayer_send(method, *args, &block)
        else
          super
        end
      end

      # Add all of the MPlayer::Slave methods to the context as instructions
      def respond_to_missing?(method, include_private = false)
        super || @player.mplayer_respond_to?(method)
      end

    end

  end
end
