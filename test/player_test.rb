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

    context "#poll_mplayer_value" do

      setup do
        @mplayer.expects(:get).once.returns("0.1\n")
      end

      teardown do
        @mplayer.unstub(:get)
      end

      should "convert string to float" do
        val = @player.send(:poll_mplayer_value, "key")
        refute_nil val
        assert_equal Float, val.class
        assert_equal 0.1, val
      end

    end

    context "#play" do

      setup do
        @player.expects(:ensure_player).once
        @mplayer.expects(:load_file).once
      end

      teardown do
        @player.unstub(:ensure_player)
        @mplayer.unstub(:load_file)
      end

      should "lazily invoke mplayer and play" do
        assert @player.play("file.mov")
        refute_nil @player.instance_variable_get("@player")
      end

    end

  end

end
