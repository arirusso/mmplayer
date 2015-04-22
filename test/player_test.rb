require "helper"

class MMPlayer::PlayerTest < Minitest::Test

  context "Player" do

    setup do
      @player = MMPlayer::Player.new
      @mplayer = Object.new
      @player.stubs(:ensure_player).returns(@mplayer)
      @player.instance_variable_set("@player", @mplayer)
    end

    teardown do
      @player.unstub(:ensure_player)
    end

    context "#mplayer_send" do

      setup do
        @player.send(:ensure_player, "")
        @mplayer.expects(:hello).once.returns(true)
        @mplayer.expects(:send).once.with(:hello).returns(true)
      end

      teardown do
        @mplayer.unstub(:send)
      end

      should "send messages to mplayer" do
        assert @player.mplayer_send(:hello)
      end

    end

    context "#mplayer_respond_to?" do

      setup do
        @player.send(:ensure_player, "")
        @mplayer.expects(:respond_to?).with(:hello).once.returns(true)
      end

      teardown do
        @mplayer.unstub(:respond_to?)
      end

      should "send messages to mplayer" do
        assert @player.mplayer_respond_to?(:hello)
      end

    end

    context "#play" do

      setup do
      end

      should "lazily invoke mplayer" do

      end

      should "send video to mplayer to play" do
      end

    end

    context "#active?" do

      should "return false when mplayer hasn't been invoked" do
      end

      should "return true when mplayer is initialized" do
      end

    end

    context "#progress" do

    end

  end
end
