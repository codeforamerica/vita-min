module DocumentTypes
  class Form1099Int < DocumentType
    class << self
      def key
        "1099-INT"
      end
    end
  end
end
