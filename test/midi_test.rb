require "helper"

class MMPlayer::MIDITest < Minitest::Test

  context "MIDI" do

    setup do
      @input = Object.new
      @midi = MMPlayer::MIDI.new(@input)
    end

    context "#note" do

      setup do
        @var = nil
        @midi.note(10) { |note| @var = note }
      end

      should "set callback" do
        refute_nil @midi.config[:note][10]
        assert_equal Proc, @midi.config[:note][10].class
      end

    end

  end
end
