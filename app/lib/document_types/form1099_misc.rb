module DocumentTypes
  class Form1099Misc < DocumentType
    class << self
      def relevant_to?(_intake)
        # Deprecated type. Merged into Employment
        false
      end

      def key
        "1099-MISC"
      end
    end
  end
end
