module DocumentTypes
  class Identity < DocumentType
    class << self
      def description
        'All of the following are included as valid forms of photo IDs: Drivers License, Employer Ids,
        Employment Authorization Document,GreenCard, Military Ids, Passport, School Ids, StateIds, Tribal Ids, and Visas'
      end

      def key
        "ID"
      end

      def blocks_progress?
        true
      end
    end
  end
end
