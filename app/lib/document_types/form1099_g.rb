module DocumentTypes
  class Form1099G < DocumentType
    class << self
      def key
        "1099-G"
      end
    end
  end
end
