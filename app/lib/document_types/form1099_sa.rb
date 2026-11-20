module DocumentTypes
  class Form1099Sa < DocumentType
    class << self
      def relevant_to?(intake)
        intake.had_hsa_yes?
      end

      def key
        "1099-SA"
      end
    end
  end
end
