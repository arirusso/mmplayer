require "helper"

class MMPlayer::PlayerTest < Minitest::Test

  context "Player" do

    setup do
      @player = MMPlayer::Player::Wrapper.new
      @mplayer = Object.new
      @mplayer.stubs(:load_file).returns(true)
      out = Object.new
      out.stubs(:gets).returns("")
      @mplayer.stubs(:stdout).returns(out)
      @mplayer.stubs(:get).returns("0.1\n")
      @player.stubs(:player).returns(@mplayer)
      @player.instance_variable_set("@player", @mplayer)
      @player.instance_variable_set("@threads", [Thread.new {}])
    end

    context "#mplayer_send" do

      setup do
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
        @mplayer.expects(:respond_to?).with(:hello).once.returns(true)
      end

      teardown do
        @mplayer.unstub(:respond_to?)
      end

      should "send messages to mplayer" do
        assert @player.mplayer_respond_to?(:hello)
      end

    end

    context "#get_percentage" do

      should "calcuate percentage" do
        val = @player.send(:get_percentage, { :length => 10.1, :position => 5.5 })
        refute_nil val
        assert_equal Fixnum, val.class
        assert_equal 54, val
      end

    end

    context "#quit" do

      setup do
        @mplayer.expects(:quit).once
        @player.instance_variable_get("@threads").first.expects(:kill).once
      end

      teardown do
        @mplayer.unstub(:quit)
        @player.instance_variable_get("@threads").first.unstub(:kill)
      end

      should "exit MPlayer and kill the player thread" do
        assert @player.quit
      end

    end

    context "#progress" do
      # TODO
    end

    context "#poll_mplayer_progress" do
      # TODO
    end

    context "#get_mplayer_float" do

      should "convert string to float" do
        val = @player.send(:get_mplayer_float, "key")
        refute_nil val
        assert_equal Float, val.class
        assert_equal 0.1, val
      end

    end

    context "#play" do

      setup do
        @player.expects(:player).once.returns(@mplayer)
      end

      teardown do
        @player.unstub(:player)
      end

      should "lazily invoke mplayer and play" do
        assert @player.play("file.mov")
        refute_nil @player.instance_variable_get("@player")
      end

    end

    context "Messenger" do

      context "#throttle?" do

        setup do
          @messenger = MMPlayer::Player::Messenger.new
          @limit = MMPlayer::Player::Messenger::FREQUENCY_LIMIT
        end

        should "respect message frequency" do
          assert @messenger.send(:throttle?, 1234, 1234 - @limit / 2)
          refute @messenger.send(:throttle?, 1234, 1234 - @limit * 2)
        end

      end

    end

  end

end
