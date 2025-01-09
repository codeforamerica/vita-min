module StateFile
  module StateIdConcern
    extend ActiveSupport::Concern

    included do
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

      validates :issue_date, presence: true, unless: -> { id_type == "no_id" }
      validates :expiration_date, presence: true, unless: -> { id_type == "no_id" || non_expiring == "1" }
      validates :state, presence: true, inclusion: { in: States.keys }, unless: -> { id_type == "no_id" }
      validates :id_type, presence: true
      validates :id_number,
                presence: true,
                length: { in: 1..40 },
                if: -> { id_type != "no_id" }
    end
  end
end
