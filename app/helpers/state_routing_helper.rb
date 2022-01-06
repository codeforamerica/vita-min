module StateRoutingHelper
  def current_routing_percentage(state_routing_target, vita_partner)
    routing_fraction = state_routing_target.state_routing_fractions.find { |srf| srf.vita_partner == vita_partner }
    routing_fraction ? routing_fraction.routing_percentage : 0
  end
end