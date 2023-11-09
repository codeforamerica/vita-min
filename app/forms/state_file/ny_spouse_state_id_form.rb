module StateFile
  class NySpouseStateIdForm < QuestionsForm
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
    validates :id_number, alphanumeric: true, length: {is: 9}, unless: -> { id_type == "no_id" }
    validate :issue_date_is_valid_date, unless: -> { id_type == "no_id" }
    validate :expiration_date_is_valid_date, unless: -> { id_type == "no_id" }
    validates :state, presence: true, inclusion: { in: States.keys }, unless: -> { id_type == "no_id" }
    validates :first_three_doc_num, alphanumeric: true, length: {is: 3}, unless: -> { id_type == "no_id" }

    def save
      @intake.update!(spouse_state_id_attributes: attributes_for(:state_id).merge(issue_date: issue_date, expiration_date: expiration_date))
    end

    def self.existing_attributes(intake)
      state_id = intake.spouse_state_id
      state_id.present? ? existing_state_id_attrs(super, state_id) : super
    end

    private

    def self.existing_state_id_attrs(attrs, state_id)
      attrs.merge(
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
    end

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