module DocumentTypes
  class Form1099A < DocumentType
    class << self
      def key
        "1099-A"
      end
    end
  end
end
