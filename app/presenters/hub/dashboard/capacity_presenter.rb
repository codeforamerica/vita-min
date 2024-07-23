module Hub
  module Dashboard
    class CapacityPresenter
      attr_reader :selected

      def initialize(selected)
        @selected = selected
      end

      def capacity
        return @capacity if @capacity
        return if @selected.instance_of? Site
        if @selected.instance_of? Coalition
          @capacity = @selected.organizations.filter { |org| org.capacity_limit.present? && org.capacity_limit.positive? }
          @capacity.sort! do |a, b|
            sort_a = (a.active_client_count.to_f / a.capacity_limit)
            sort_b = (b.active_client_count.to_f / b.capacity_limit)
            sort_b <=> sort_a
          end
        elsif @selected.instance_of?(Organization) && @selected.capacity_limit
          @capacity = [@selected]
        end
      end

      def capacity_count
        if @selected.instance_of? Coalition
          @selected.organizations.count(&:capacity_limit)
        elsif @selected.instance_of?(Organization) && selected.capacity_limit
          1
        else
          0
        end
      end
    end
  end
end