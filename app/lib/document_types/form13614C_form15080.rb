module DocumentTypes
  class Form13614CForm15080 < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        # and will likely be deprecated after we implement client authentication
        false
      end

      def key
        "F13614C / F15080 2020"
      end

      def blocks_progress?
        false
      end
    end
  end
end
