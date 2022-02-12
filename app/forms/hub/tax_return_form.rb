module Hub
  class TaxReturnForm < Form
    include FormAttributes

    attr_accessor :tax_return, :tax_return_years, :remaining_years

    set_attributes_for :tax_return,
                       :year,
                       :assigned_user_id,
                       :certification_level,
                       :service_type
    set_attributes_for :state_transition, :current_state
    validates :current_state, presence: true
    validates :year, presence: true

    def initialize(client, params={})
      @client = client
      super(params)
      @service_type ||= "drop_off" if client.tax_returns.pluck(:service_type).include? "drop_off"
      @current_state ||= "intake_in_progress"
      @tax_return = @client.tax_returns.new
    end

    def save
      @tax_return.assign_attributes(attributes_for(:tax_return))
      @tax_return.save!
      tax_return.transition_to!(current_state)
    end

    def self.permitted_params
      [:service_type, :year, :assigned_user_id, :current_state, :certification_level, :service_type]
    end

    def tax_return_years
      @client.tax_returns.pluck(:year)
    end

    def remaining_years
      TaxReturn.filing_years - tax_return_years
    end
  end
end
