module Hub
  class CoalitionForm < Form
    include FormAttributes

    attr_accessor :coalition

    set_attributes_for :coalition, :name
    set_attributes_for :state_routing_targets, :states

    def initialize(coalition = nil, params = {})
      @coalition = coalition
      super(params)
    end

    def save
      coalition.assign_attributes(attributes_for(:coalition))
      UpdateStateRoutingTargetsService.update(coalition, states.split(","))
      coalition.save
    end
  end
end
