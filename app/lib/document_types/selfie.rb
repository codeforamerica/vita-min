module DocumentTypes
  class Selfie < DocumentType
    class << self
      def key
        "Selfie"
      end

      def blocks_progress?
        true
      end
    end
  end
end
