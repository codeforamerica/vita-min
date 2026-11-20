module DocumentTypes
  class Form1099Div < DocumentType
    class << self
      def key
        "1099-DIV"
      end
    end
  end
end
