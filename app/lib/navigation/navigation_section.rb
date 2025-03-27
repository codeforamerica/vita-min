module Navigation
  class NavigationSection
    attr_accessor :title, :steps, :increment_step, :df_data_required
    # Indicates whether this step contributes to the overall count (Cancel / Failure steps typically don't)
    alias_method :increment_step?, :increment_step

    def initialize(title, steps, increment_step = true, df_data_required = false)
      @title = title
      @steps = steps
      @increment_step = increment_step
      @df_data_required = df_data_required
    end

    def controllers
      @steps.flat_map(&:controllers)
    end

    def pages(visitor_record)
      @steps.flat_map { |step| step.pages(visitor_record) }
    end
  end
end
