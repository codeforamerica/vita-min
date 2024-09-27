module StateFile
  class NcPrimaryStateIdForm < QuestionsForm
    # Validation /attribute set up
    include StateFile::NcStateIdConcern

    def initialize(intake, params = nil)
      intake.build_primary_state_id unless intake.primary_state_id
      attribute_subset = intake.primary_state_id
        .attributes
        # Looks at the attribute hash available on the primary state id and
        # takes out the bits irrelvant to us for this form
        .slice(
          *attribute_names.map(&:to_s)
        )

      # Assigns default values if the object exists
      assign_attributes(attribute_subset) if intake.primary_state_id
      super(intake, params)
    end

    def save
      @intake.update!(
        primary_state_id_attributes: {
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
