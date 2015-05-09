require "helper"

class MMPlayer::ContextTest < Minitest::Test

  context "Context" do

    setup do
      @input = Object.new
      @context = MMPlayer::Context.new(@input)
      @player = Object.new
      @context.player.stubs(:player).returns(@player)
      @context.player.stubs(:quit).returns(true)
      @context.player.stubs(:active?).returns(true)
    end

    teardown do
      @context.player.unstub(:player)
      @context.player.unstub(:quit)
      @context.player.unstub(:active?)
    end

    context "#start" do

      setup do
        @context.midi.listener.expects(:on_message).once
        @context.midi.listener.expects(:start).once
      end

      teardown do
        @context.midi.listener.unstub(:on_message)
        @context.midi.listener.unstub(:start)
      end

      should "activate player" do
        assert @context.start(:background => true)
        assert @context.stop
      end

    end

    context "#stop" do

      setup do
        @context.midi.listener.expects(:on_message).once
        @context.midi.listener.expects(:start).once
        @context.midi.listener.expects(:stop).once
        @context.player.expects(:quit).once
        assert @context.start(:background => true)
      end

      teardown do
        @context.midi.listener.unstub(:on_message)
        @context.midi.listener.unstub(:start)
        @context.player.unstub(:quit)
      end

      should "stop player" do
        assert @context.stop
      end

    end

  end
end
