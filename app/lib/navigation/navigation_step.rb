module Navigation
  class NavigationStep
    attr_accessor :controller, :is_step, :show_steps
    alias_method :increment_step?, :is_step
    alias_method :show_steps?, :show_steps

    def initialize(controller, increment_step: true, show_steps: true)
      @controller = controller
      @increment_step = increment_step
      @show_steps = show_steps
    end
  end
end
