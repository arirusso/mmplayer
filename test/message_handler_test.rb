require "helper"

class MMPlayer::MessageHandlerTest < Minitest::Test

  context "MessageHandler" do

    setup do
      @handler = MMPlayer::MessageHandler.new
    end

    context "#note_message" do

      setup do
        @message = MIDIMessage::NoteOn.new(0, 10, 100)
      end

      context "callback exists" do

        setup do
          @var = nil
          @callback = proc { |vel| @var = vel }
          @handler.add_callback(:note, @message.note, &@callback)
          @callback.expects(:call).once
        end

        teardown do
          @callback.unstub(:call)
        end

        context "has catch-all callback" do

          setup do
            @var2 = nil
            @catchall = proc { |vel| @var2 = vel }
            @handler.add_callback(:note, nil, &@catchall)
            @catchall.expects(:call).never
          end

          should "call specific callback" do
            assert @handler.send(:note_message, @message)
          end

        end

        context "no catch-all callback" do

          should "call specific callback" do
            assert @handler.send(:note_message, @message)
          end

        end

      end

      context "callback doesn't exist" do

        context "has catch-all callback" do

          setup do
            @var = nil
            @callback = proc { |vel| @var = vel }
            @handler.add_callback(:note, nil, &@callback)
            @callback.expects(:call).once
          end

          should "call callback" do
            assert @handler.send(:note_message, @message)
          end

        end

        context "no catch-all callback" do

          should "do nothing" do
            refute @handler.send(:note_message, @message)
          end

        end

      end

    end

    context "#cc_message" do

      setup do
        @message = MIDIMessage::ControlChange.new(0, 8, 100)
      end

      context "callback exists" do

        setup do
          @var = nil
          @callback = proc { |vel| @var = vel }
          @handler.add_callback(:cc, @message.index, &@callback)
          @callback.expects(:call).once
        end

        teardown do
          @callback.unstub(:call)
        end

        should "call callback" do
          assert @handler.send(:cc_message, @message)
        end

      end

      context "callback doesn't exist" do

        context "has catch-all callback" do

          setup do
            @var = nil
            @callback = proc { |vel| @var = vel }
            @handler.add_callback(:cc, nil, &@callback)
            @callback.expects(:call).once
          end

          should "call callback" do
            assert @handler.send(:cc_message, @message)
          end

        end

        context "no catch-all callback" do

          should "do nothing" do
            refute @handler.send(:cc_message, @message)
          end

        end

      end

    end

    context "#system_message" do

      setup do
        @message = MIDIMessage::SystemRealtime.new(0x8) # clock
      end

      context "callback exists" do

        setup do
          @var = nil
          @callback = proc { |vel| @var = vel }
          @handler.add_callback(:system, :clock, &@callback)
          @callback.expects(:call).once
        end

        teardown do
          @callback.unstub(:call)
        end

        should "call callback" do
          assert @handler.send(:system_message, @message)
        end

      end

      context "callback doesn't exist" do

        should "do nothing" do
          refute @handler.send(:system_message, @message)
        end

      end

    end

    context "#channel_message" do

      context "omni" do

        setup do
          @channel = nil
        end

        context "control change" do

          setup do
            @message = MIDIMessage::ControlChange.new(0, 8, 100)
            @handler.expects(:cc_message).once.with(@message).returns(true)
          end

          teardown do
            @handler.unstub(:cc_message)
          end

          should "handle control change" do
            assert @handler.send(:channel_message, @channel, @message)
          end

        end

        context "note" do

          setup do
            @message = MIDIMessage::NoteOn.new(0, 10, 100)
            @handler.expects(:note_message).once.with(@message).returns(true)
          end

          teardown do
            @handler.unstub(:note_message)
          end

          should "handle note" do
            assert @handler.send(:channel_message, @channel, @message)
          end

        end

      end

      context "with channel" do

        setup do
          @channel = 5
        end

        context "control change" do

          setup do
            @message = MIDIMessage::ControlChange.new(@channel, 8, 100)
          end

          context "matching channel" do

            setup do
              @handler.expects(:cc_message).once.with(@message).returns(true)
            end

            teardown do
              @handler.unstub(:cc_message)
            end

            should "handle control change" do
              assert @handler.send(:channel_message, @channel, @message)
            end

          end

          context "non matching channel" do

            setup do
              @handler.expects(:cc_message).never
              @other_message = MIDIMessage::ControlChange.new(@channel + 1, 8, 100)
            end

            teardown do
              @handler.unstub(:cc_message)
            end

            should "do nothing" do
              refute @handler.send(:channel_message, @channel, @other_message)
            end

          end

        end

        context "note" do

          setup do
            @message = MIDIMessage::NoteOn.new(@channel, 10, 100)
          end

          context "matching channel" do

            setup do
              @handler.expects(:note_message).once.with(@message).returns(true)
            end

            teardown do
              @handler.unstub(:note_message)
            end

            should "call callback" do
              assert @handler.send(:channel_message, @channel, @message)
            end

          end

          context "non matching channel" do

            setup do
              @handler.expects(:note_message).never
              @other_message = MIDIMessage::ControlChange.new(@channel + 1, 8, 100)
            end

            teardown do
              @handler.unstub(:note_message)
            end

            should "not call callback" do
              refute @handler.send(:channel_message, @channel, @other_message)
            end

          end

        end

      end

    end

  end

end
