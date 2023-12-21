module StateFile
  class NySpouseStateIdForm < NyPrimaryStateIdForm
    set_attributes_for :state_id,
                       :id_type,
                       :id_number,
                       :state,
                       :first_three_doc_num,
                       :non_expiring

    set_attributes_for :dates,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year

    private

    def self.record_type
      :spouse_state_id
    end
  end
end