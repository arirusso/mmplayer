module MMPlayer

  module Thread

    extend self

    def new(&block)
      thread = ::Thread.new do
        begin
          yield
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      thread.abort_on_exception = true
      thread
    end

  end

end
