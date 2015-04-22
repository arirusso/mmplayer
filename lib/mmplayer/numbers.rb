module MMPlayer

  module Numbers

    def percent(num)
      Scale.transform(num).from(0..127).to(0..100)
    end

  end

end
