module DocumentTypes
  class W2 < DocumentType
    class << self
      def relevant_to?(_intake)
        # Deprecated type. Merged into Employment
        false
      end

      def key
        "W-2"
      end
    end
  end
end
