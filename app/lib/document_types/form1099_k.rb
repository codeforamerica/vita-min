module DocumentTypes
  class Form1099K < DocumentType
    class << self
      def relevant_to?(_intake)
        # Deprecated type. Merged into Employment
        false
      end

      def key
        "1099-K"
      end
    end
  end
end
