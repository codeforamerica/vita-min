module StateFile
  class NcPrimaryStateIdForm < QuestionsForm
    include DateAccessible

    set_attributes_for :state_id,
                       :id,
                       :expiration_date,
                       :expiration_date_day,
                       :expiration_date_month,
                       :expiration_date_year,
                       :issue_date,
                       :issue_date_day,
                       :issue_date_month,
                       :issue_date_year,
                       :non_expiring,
                       :state,
                       :id_number,
                       :id_type

    # Position is important. Must be below `set_attributes_for` to overwrite the standard `attr_accessor`s
    date_accessor :expiration_date, :issue_date

    validates :issue_date, presence: true
    validates :expiration_date, presence: true
    validates :state, presence: true, inclusion: { in: States.keys }
    validates :id_type, presence: true
    validates :id_number, presence: true, alphanumeric: true

    def initialize(intake, params = nil)
      super(intake, params)

      assign_attributes(intake.primary_state_id.attributes)
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
