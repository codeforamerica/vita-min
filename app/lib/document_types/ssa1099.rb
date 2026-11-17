module DocumentTypes
  class Ssa1099 < DocumentType
    class << self
      def key
        "SSA-1099"
      end

      def description
        "It should say SSA-1099 and Social Security Benefit Statement on the top of the document"
      end
    end
  end
end
