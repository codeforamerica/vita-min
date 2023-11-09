module StateFile
  class NyPrimaryStateIdForm < QuestionsForm
    include DateHelper
    set_attributes_for :state_id, :id_type, :id_number, :state, :first_three_doc_num

    set_attributes_for :dates,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year

    validates :id_type, presence: true
    validates :id_number, presence: true, alphanumeric: true
    validates :state, presence: true, inclusion: { in: States.keys }
    validate :issue_date_is_valid_date
    validate :expiration_date_is_valid_date

    def save
      @intake.update!(primary_state_id_attributes: attributes_for(:state_id).merge(issue_date: issue_date, expiration_date: expiration_date))
    end

    def self.existing_attributes(intake)
      if intake.primary_state_id.present?
        state_id = intake.primary_state_id
        super.merge(
          id_type: state_id.id_type,
          id_number: state_id.id_number,
          first_three_doc_num: state_id.first_three_doc_num,
          state: state_id.state,
          issue_date_day: state_id.issue_date&.day,
          issue_date_month: state_id.issue_date&.month,
          issue_date_year: state_id.issue_date&.year,
          expiration_date_day: state_id.expiration_date&.day,
          expiration_date_month: state_id.expiration_date&.month,
          expiration_date_year: state_id.expiration_date&.year,
          )
      else
        super
      end
    end

    private

    def issue_date
      parse_date_params(issue_date_year, issue_date_month, issue_date_day)
    end

    def issue_date_is_valid_date
      valid_text_date(issue_date_year, issue_date_month, issue_date_day, :issue_date)
    end

    def expiration_date
      parse_date_params(expiration_date_year, expiration_date_month, expiration_date_day)
    end

    def expiration_date_is_valid_date
      valid_text_date(expiration_date_year, expiration_date_month, expiration_date_day, :expiration_date)
    end

  end
end