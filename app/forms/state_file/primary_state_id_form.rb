module StateFile
  class PrimaryStateIdForm < StateIdForm
    def self.existing_attributes(intake)
      intake.build_primary_state_id unless intake.primary_state_id
      HashWithIndifferentAccess.new(intake.primary_state_id.attributes)
    end

    def self.record_type
      :primary_state_id
    end
  end
end