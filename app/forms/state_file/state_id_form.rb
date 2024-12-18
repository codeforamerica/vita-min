module StateFile
  class StateIdForm < QuestionsForm
    # Validation /attribute set up common across both state ids
    include StateFile::StateIdConcern

    def save
      @intake.update!(
        :"#{self.class.record_type}_attributes" => {
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
