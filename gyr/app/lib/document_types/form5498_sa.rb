module DocumentTypes
  class Form5498Sa < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_hsa_yes?
      end

      def key
        "5498-SA"
      end
    end
  end
end
