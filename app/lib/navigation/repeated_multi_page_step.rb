module Navigation
  class RepeatedMultiPageStep
    attr_accessor :controllers, :step_name, :show_steps
    # Indicates whether navigation widget should be displayed on these steps
    alias show_steps? show_steps

    def initialize(step_name, controllers, item_count_proc, show_steps: true)
      @step_name = step_name
      @controllers = controllers
      @item_count_proc = item_count_proc
      @show_steps = show_steps
    end

    def pages(visitor_record)
      num_items = @item_count_proc.call(visitor_record)
      num_items.times.flat_map do |i|
        @controllers.map { |controller| { item_index: i, controller: controller, step: step_name } }
      end
    end
  end
end
