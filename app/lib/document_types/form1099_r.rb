module DocumentTypes
  class Form1099R < DocumentType
    class << self
      def key
        "1099-R"
      end
    end
  end
end
