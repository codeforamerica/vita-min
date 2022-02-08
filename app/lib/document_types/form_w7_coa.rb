module DocumentTypes
  class FormW7Coa < DocumentType
    class << self
      def relevant_to?(intake)
        false
      end

      def key
        "Form W-7 (COA)"
      end

      def blocks_progress?
        false
      end
    end
  end
end
