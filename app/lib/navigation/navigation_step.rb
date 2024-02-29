module Navigation
  class NavigationStep
    attr_accessor :controller, :show_steps
    # Indicates whether navigation widget should be displayed on this step
    alias_method :show_steps?, :show_steps

    def initialize(controller, show_steps = true)
      @controller = controller
      @show_steps = show_steps
    end
  end
end
