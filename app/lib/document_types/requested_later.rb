module DocumentTypes
  class RequestedLater < DocumentType
    class << self
      def key
        "Requested Later"
      end

      def blocks_progress?
        true
      end
    end
  end
end
