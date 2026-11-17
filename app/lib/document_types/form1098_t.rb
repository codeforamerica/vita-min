module DocumentTypes
  class Form1098T < DocumentType
    class << self
      def key
        "1098-T"
      end
    end
  end
end
