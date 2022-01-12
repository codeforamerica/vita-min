class WeightedRoutingService
  def initialize(collection)
    @collection = collection.reject { |obj| obj.routing_fraction.zero? }
    @balanced_total = collection.sum(&:routing_fraction)
  end

  def weighted_routing_ranges
    routing_ranges = []
    next_range_start = 0.0
    @collection.each_with_index do |obj|
      applied_routing_fraction = balanced_routing_fraction(obj.routing_fraction)

      range = { id: obj.vita_partner_id }
      range[:low] = next_range_start
      range[:high] = applied_routing_fraction + next_range_start
      next_range_start += applied_routing_fraction
      routing_ranges << range
    end
    routing_ranges.last[:high] = 1 unless routing_ranges.empty?
    routing_ranges
  end

  private

  def balanced_routing_fraction(routing_fraction)
    (routing_fraction / @balanced_total).round(4)
  end
end
