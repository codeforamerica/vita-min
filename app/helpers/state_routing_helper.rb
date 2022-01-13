module StateRoutingHelper
  def current_routing_fraction(state_routing_target, vita_partner)
    state_routing_target.state_routing_fractions.find { |srf| srf.vita_partner == vita_partner }
  end
end