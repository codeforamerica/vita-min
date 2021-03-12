class WeightedRoutingService
  def initialize(collection)
    @collection = collection
    @balanced_total = @collection.sum(:routing_fraction)
  end

  def weighted_routing_ranges
    routing_ranges = []

    @collection.each_with_index do |obj, i|
      next if obj.routing_fraction.zero?

      applied_routing_fraction = balanced_routing_fraction(obj.routing_fraction)
      range = { id: obj.vita_partner_id }
      if i.zero?
        range[:low] = 0.0
        range[:high] = applied_routing_fraction
      else
        range[:low] = routing_ranges.last[:high]
        range[:high] = i == @collection.count - 1 ? 1.0 : range[:low] + applied_routing_fraction
      end
      routing_ranges << range
    end
    routing_ranges
  end

  private

  def balanced_routing_fraction(routing_fraction)
    (routing_fraction / @balanced_total).round(4)
  end
end