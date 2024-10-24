module StateFile
  class SpouseStateIdForm < StateIdForm
    def self.existing_attributes(intake)
      intake.build_spouse_state_id unless intake.spouse_state_id
      HashWithIndifferentAccess.new(intake.spouse_state_id.attributes)
    end

    def self.record_type
      :spouse_state_id
    end
  end
end