module StateFile
  class NyPrimaryStateIdForm < StateIdForm
    include DateHelper
    set_attributes_for :state_id, :id_type, :id_number, :state, :first_three_doc_num

    set_attributes_for :dates,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year

    validates :first_three_doc_num, alphanumeric: true, length: {is: 3}, unless: -> { id_type == "no_id" }

    def save
      @intake.update!(primary_state_id_attributes: attributes_for(:state_id).merge(issue_date: issue_date, expiration_date: expiration_date))
    end

    private

    def self.state_id(intake)
      intake.primary_state_id
    end

    def self.existing_state_id_attrs(state_id)
      super.merge(
        first_three_doc_num: state_id.first_three_doc_num,
      )
    end
  end
end