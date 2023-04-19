module Hub
  class CoalitionForm < Form
    include FormAttributes

    attr_accessor :coalition

    set_attributes_for :coalition, :name
    set_attributes_for :state_routing_targets, :states

    validates :name, presence: true

    def initialize(coalition = nil, params = {})
      @coalition = coalition
      super(params)
    end

    def save
      return false unless valid?

      coalition.assign_attributes(attributes_for(:coalition))
      if states
        UpdateStateRoutingTargetsService.update(coalition, states.split(","))
      end
      coalition.save
    end
  end
end
