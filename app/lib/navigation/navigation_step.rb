module Navigation
  class NavigationStep
    attr_accessor :controller, :increment_step, :show_steps
    # Indicates whether this step contributes to the overall count (Cancel / Failure steps typically don't)
    alias_method :increment_step?, :increment_step
    # Indicates whether navigation widget should be displayed on this step
    alias_method :show_steps?, :show_steps

    def initialize(controller, increment_step=true, show_steps=true)
      @controller = controller
      @increment_step = increment_step
      @show_steps = show_steps
    end
  end
end
