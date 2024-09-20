module StateFile
  class NcPrimaryStateIdForm < QuestionsForm
    include DateAccessible

    set_attributes_for :state_id,
                       :expiration_date,
                       :issue_date,
                       :non_expiring,
                       :state,
                       :id_number,
                       :id_type

    date_accessor :issue_date, :expiration_date

    validates :issue_date, presence: true
    validates :expiration_date, presence: true
    validates :state, presence: true, inclusion: { in: States.keys }
    validates :id_type, presence: true
    validates :id_number, presence: true, alphanumeric: true

    # def valid?
    #   raise Error.new
    #   super
    # end

    def save
      @intake.update!(primary_state_id_attributes: attributes_for(:state_id).merge(issue_date: issue_date, expiration_date: expiration_date))
    end
  end
end
