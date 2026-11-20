module DocumentTypes
  class Form1099B < DocumentType
    class << self
      def key
        "1099-B"
      end
    end
  end
end
