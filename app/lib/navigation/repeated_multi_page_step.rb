module Navigation
  class RepeatedMultiPageStep
    attr_accessor :controllers, :show_steps
    # Indicates whether navigation widget should be displayed on these steps
    alias show_steps? show_steps

    def initialize(controllers, item_count_proc, show_steps: true)
      @controllers = controllers
      @show_steps = show_steps
      @item_count_proc = item_count_proc
    end

    def pages(object_for_flow)
      num_items = @item_count_proc.call(object_for_flow)
      num_items.times.flat_map do |i|
        @controllers.map { |controller| { item_index: i, controller: controller } }
      end
    end

  end
end
