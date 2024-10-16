module StateFile
  class NcSpouseStateIdForm < QuestionsForm
    # Validation / attribute set up common across both state ids
    include StateFile::NcStateIdConcern

    def self.existing_attributes(intake)
      intake.build_spouse_state_id unless intake.spouse_state_id
      HashWithIndifferentAccess.new(intake.spouse_state_id.attributes)
    end

    def save
      @intake.update!(
        spouse_state_id_attributes: {
          issue_date: issue_date,
          expiration_date: expiration_date,
          non_expiring: non_expiring,
          id_type: id_type,
          id_number: id_number,
          state: state,
        }
      )
    end
  end
end
