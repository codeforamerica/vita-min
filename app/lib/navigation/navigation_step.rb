module Navigation
  class NavigationStep
    attr_accessor :controller, :show_steps, :requires_completed
    # Indicates whether navigation widget should be displayed on this step
    alias_method :show_steps?, :show_steps

    def initialize(controller, show_steps = true, requires_completed = nil)
      @controller = controller
      @show_steps = show_steps
      @requires_completed = requires_completed
    end
  end
end
