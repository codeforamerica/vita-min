module StateFile
  class NyPrimaryStateIdForm < StateIdForm
    include DateHelper
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

    validates :first_three_doc_num, alphanumeric: true, length: {is: 3}, unless: -> { id_type == "no_id" }

    private

    def self.record_type
      :primary_state_id
    end

    def self.existing_state_id_attrs(state_id)
      super.merge(
        first_three_doc_num: state_id.first_three_doc_num,
      )
    end
  end
end