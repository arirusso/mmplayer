module MMPlayer

  module Numbers

    def to_percent(num)
      Scale.transform(num).from(0..127).to(0..100)
    end
    
  end

end
