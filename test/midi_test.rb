require "helper"

class MMPlayer::MIDITest < Minitest::Test

  context "MIDI" do

    setup do
      @input = Object.new
      @midi = MMPlayer::MIDI.new(@input)
    end

    context "#start" do

      setup do
        @midi.listener.expects(:on_message).twice
        @midi.listener.expects(:start).once
      end

      teardown do
        @midi.listener.unstub(:on_message)
        @midi.listener.unstub(:start)
      end

      should "activate callbacks" do
        assert @midi.start
      end

    end

    context "#add_note_callback" do

      setup do
        @var = nil
        @midi.add_note_callback(10) { |vel| @var = vel }
      end

      should "store callback" do
        refute_nil @midi.config[:note][10]
        assert_equal Proc, @midi.config[:note][10].class
      end

    end

    context "#add_cc_callback" do

      setup do
        @var = nil
        @midi.add_cc_callback(2) { |val| @var = val }
      end

      should "store callback" do
        refute_nil @midi.config[:cc][2]
        assert_equal Proc, @midi.config[:cc][2].class
      end

    end

  end
end
