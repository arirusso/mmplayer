require "helper"

class MMPlayer::MIDI::WrapperTest < Minitest::Test

  context "Wrapper" do

    setup do
      @input = Object.new
      @midi = MMPlayer::MIDI::Wrapper.new(@input)
    end

    context "#handle_new_event" do

      context "with no buffer length" do

        setup do
          @midi.message_handler.expects(:process).once
          @event = {
            :message => MIDIMessage::NoteOn.new(0, 64, 120),
            :timestamp=> 9266.395330429077
          }
          @result = @midi.send(:handle_new_event, @event)
        end

        teardown do
          @midi.message_handler.unstub(:process)
        end

        should "return event" do
          refute_nil @result
          assert_equal @event, @result
        end

      end

      context "with buffer length" do

        context "recent message" do

          setup do
            @midi.message_handler.expects(:process).once
            @event = {
              :message => MIDIMessage::NoteOn.new(0, 64, 120),
              :timestamp=> 9266.395330429077
            }
            @result = @midi.send(:handle_new_event, @event)
          end

          teardown do
            @midi.message_handler.unstub(:process)
          end

          should "return event" do
            refute_nil @result
            assert_equal @event, @result
          end

        end

        context "with too-old message" do

          setup do
            @midi.instance_variable_set("@buffer_length", 1)
            @midi.instance_variable_set("@start_time", Time.now.to_i)
            sleep(2)
            @midi.message_handler.expects(:process).never
            @event = {
              :message => MIDIMessage::NoteOn.new(0, 64, 120),
              :timestamp => 0.1
            }
            @result = @midi.send(:handle_new_event, @event)
          end

          teardown do
            @midi.message_handler.unstub(:process)
          end

          should "not return event" do
            assert_nil @result
          end

        end

      end

    end

    context "#initialize_listener" do

      setup do
        @midi.listener.expects(:on_message).once
        @result = @midi.send(:initialize_listener)
      end

      teardown do
        @midi.listener.unstub(:on_message)
      end

      should "return listener" do
        refute_nil @result
        assert_equal MIDIEye::Listener, @result.class
      end

    end

    context "#start" do

      setup do
        @midi.listener.expects(:on_message).once
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
        refute_nil @midi.message_handler.callback[:note][10]
        assert_equal Proc, @midi.message_handler.callback[:note][10].class
      end

    end

    context "#add_system_callback" do

      setup do
        @var = nil
        @midi.add_system_callback(:start) { |val| @var = val }
      end

      should "store callback" do
        refute_nil @midi.message_handler.callback[:system][:start]
        assert_equal Proc, @midi.message_handler.callback[:system][:start].class
      end

    end

    context "#add_cc_callback" do

      setup do
        @var = nil
        @midi.add_cc_callback(2) { |val| @var = val }
      end

      should "store callback" do
        refute_nil @midi.message_handler.callback[:cc][2]
        assert_equal Proc, @midi.message_handler.callback[:cc][2].class
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
          refute @midi.omni?
        end

        should "set channel nil" do
          assert_equal nil, @midi.channel = nil
          assert_nil @midi.channel
          assert @midi.omni?
        end
      end

      context "after listener is started" do

        setup do
          @listener.stubs(:running?).returns(true)
          @listener.expects(:clear).once
          @listener.expects(:on_message).once
        end

        should "change channel" do
          assert_equal 3, @midi.channel = 3
          assert_equal 3, @midi.channel
          refute @midi.omni?
        end

        should "set channel nil" do
          assert_equal nil, @midi.channel = nil
          assert_nil @midi.channel
          assert @midi.omni?
        end

      end

    end

  end

end
