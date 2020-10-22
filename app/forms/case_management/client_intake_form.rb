module CaseManagement
  class ClientIntakeForm < Form
    include FormAttributes
    set_attributes_for :intake, :primary_first_name, :primary_last_name
    validates :primary_first_name, presence: true, allow_blank: false
    validates :primary_last_name, presence: true, allow_blank: false

    def initialize(intake, params = {})
      @intake = intake
      super(params)
    end

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end