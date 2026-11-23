module DocumentTypes
  class Form1099S < DocumentType
    class << self
      def key
        "1099-S"
      end
    end
  end
end
