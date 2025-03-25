module Navigation
  class RepeatedSteps
    attr_accessor :controllers, :show_steps
    # Indicates whether navigation widget should be displayed on these steps
    alias show_steps? show_steps

    def initialize(controllers, show_steps: true, &item_count_block)
      @controllers = controllers
      @show_steps = show_steps
      @item_count_block = item_count_block
    end

    def steps
      num_items = @item_count_block.call
      controllers * num_items
    end

  end
end
