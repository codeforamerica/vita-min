module DocumentTypes
  class Form1099C < DocumentType
    class << self
      def key
        "1099-C"
      end
    end
  end
end
