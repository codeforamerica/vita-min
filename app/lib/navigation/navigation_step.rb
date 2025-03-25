module Navigation
  class NavigationStep
    attr_accessor :show_steps
    # Indicates whether navigation widget should be displayed on this step
    alias show_steps? show_steps

    def initialize(controller, show_steps = true)
      @controller = controller
      @show_steps = show_steps
    end

    def controllers
      [@controller]
    end

    def steps
      [@controller]
    end
    
  end
end
