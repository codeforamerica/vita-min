module DocumentTypes
  class Form1040 < DocumentType
    class << self
      def relevant_to?(intake)
        false
      end

      def key
        "Form 1040"
      end
    end
  end
end
