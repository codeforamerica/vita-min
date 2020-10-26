module DocumentTypes
  class Original13614C < DocumentType
    class << self
      def relevant_to?(intake)
        # This is not used in a flow or to determine relevant types for an intake
        # and will likely be deprecated after we implement client authentication
        false
      end

      def key
        "Original 13614-C"
      end

      def blocks_progress?
        false
      end
    end
  end
end
