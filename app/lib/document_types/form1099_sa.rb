module DocumentTypes
  class Form1099Sa < DocumentType
    class << self
      def key
        "1099-SA"
      end
    end
  end
end
