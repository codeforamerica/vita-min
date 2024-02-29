module Navigation
  class NavigationSection
    attr_accessor :title, :steps, :increment_step
    # Indicates whether this step contributes to the overall count (Cancel / Failure steps typically don't)
    alias_method :increment_step?, :increment_step

    def initialize(title, steps, increment_step = true)
      @title = title
      @steps = steps
      @increment_step = increment_step
    end

    def controllers
      @steps.map(&:controller)
    end
  end
end
