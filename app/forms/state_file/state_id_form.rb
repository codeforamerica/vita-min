module StateFile
  class StateIdForm < QuestionsForm
    include DateHelper

    validates :id_type, presence: true
    validates :id_number, alphanumeric: true, length: {is: 9}, unless: -> { id_type == "no_id" }
    validate :issue_date_is_valid_date, unless: -> { id_type == "no_id" }
    validate :expiration_date_is_valid_date, unless: -> { id_type == "no_id" }
    validates :state, presence: true, inclusion: { in: States.keys }, unless: -> { id_type == "no_id" }

    def save
      raise NotImplementedError, "Implement this method in a child class"
    end

    def self.existing_attributes(intake)
      self.state_id(intake).present? ? existing_state_id_attrs(self.state_id(intake)) : {}
    end

    private

    def self.state_id(intake)
      raise NotImplementedError, "Implement this method in a child class"
    end

    def self.existing_state_id_attrs(state_id)
      {
        id_type: state_id.id_type,
        id_number: state_id.id_number,
        state: state_id.state,
        issue_date_day: state_id.issue_date&.day,
        issue_date_month: state_id.issue_date&.month,
        issue_date_year: state_id.issue_date&.year,
        expiration_date_day: state_id.expiration_date&.day,
        expiration_date_month: state_id.expiration_date&.month,
        expiration_date_year: state_id.expiration_date&.year,
      }
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