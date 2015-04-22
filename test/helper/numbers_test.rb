require "helper"

class MMPlayer::Helper::NumbersTest < Minitest::Test

  context "Numbers" do

    setup do
      @util = Object.new
      @util.class.send(:include, MMPlayer::Helper::Numbers)
    end

    context "#to_midi_value" do

      should "convert 0" do
        val = @util.to_midi_value(0)
        refute_nil val
        assert_equal 0x0, val
      end

      should "convert 64" do
        val = @util.to_midi_value(50)
        refute_nil val
        assert_equal 0x40, val
      end

      should "convert 127" do
        val = @util.to_midi_value(100)
        refute_nil val
        assert_equal 0x7F, val
      end

    end

    context "#to_percent" do

      should "convert 0%" do
        val = @util.to_percent(0x0)
        refute_nil val
        assert_equal 0, val
      end

      should "convert 50%" do
        val = @util.to_percent(0x40)
        refute_nil val
        assert_equal 50, val
      end

      should "convert 100%" do
        val = @util.to_percent(0x7F)
        refute_nil val
        assert_equal 100, val
      end

    end

  end
end
