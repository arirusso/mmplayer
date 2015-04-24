require "helper"

class MMPlayer::MIDITest < Minitest::Test

  context "MIDI" do

    setup do
      @input = Object.new
      @midi = MMPlayer::MIDI.new(@input)
    end

    context "#start" do

      setup do
        @midi.listener.expects(:on_message).times(3)
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

    context "#add_system_callback" do

      setup do
        @var = nil
        @midi.add_system_callback(:start) { |val| @var = val }
      end

      should "store callback" do
        refute_nil @midi.config[:system][:start]
        assert_equal Proc, @midi.config[:system][:start].class
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

    context "#channel=" do

      setup do
        # stub out MIDIEye
        @listener = Object.new
        @listener.stubs(:event).returns([])
        @midi.instance_variable_set("@listener", @listener)
      end

      teardown do
        @listener.unstub(:clear)
        @listener.unstub(:on_message)
        @listener.unstub(:event)
        @listener.unstub(:running?)
      end

      context "before listener is started" do

        setup do
          @listener.stubs(:running?).returns(false)
          @listener.expects(:clear).never
          @listener.expects(:on_message).never
        end

        should "change channel" do
          assert_equal 3, @midi.channel = 3
          assert_equal 3, @midi.channel
        end

        should "set channel nil" do
          assert_equal nil, @midi.channel = nil
          assert_nil @midi.channel
        end
      end

      context "after listener is started" do

        setup do
          @listener.stubs(:running?).returns(true)
          @listener.expects(:clear).once
          @listener.expects(:on_message).times(3)
        end

        should "change channel" do
          assert_equal 3, @midi.channel = 3
          assert_equal 3, @midi.channel
        end

        should "set channel nil" do
          assert_equal nil, @midi.channel = nil
          assert_nil @midi.channel
        end

      end

    end

  end
end
