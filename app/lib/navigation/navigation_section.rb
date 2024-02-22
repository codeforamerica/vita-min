module Navigation
  class NavigationSection
    attr_accessor :title, :steps

    def initialize(title, steps)
      @title = title
      @steps = steps
    end
  end
end
