module StateFile
  class NySpouseStateIdForm < NyPrimaryStateIdForm
    set_attributes_for :state_id, :id_type, :id_number, :state, :first_three_doc_num

    set_attributes_for :dates,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year

    def save
      @intake.update!(spouse_state_id_attributes: attributes_for(:state_id).merge(issue_date: issue_date, expiration_date: expiration_date))
    end

    private

    def self.state_id(intake)
      intake.spouse_state_id
    end
  end
end