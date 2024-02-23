module Navigation
  class NavigationSection
    attr_accessor :title, :steps

    def initialize(title, steps)
      @title = title
      @steps = steps
    end

    def controllers
      @steps.map(&:controller)
    end

    def get_progress(controller)
      binding.pry
      step_number = 0
      step = @steps.detect do |s|
        return true if s.controller == controller
        step_number += 1 if s.increment_step?
        false
      end
      if step.present? && step.show_steps?
        {
          step_number: step_number,
          number_of_steps: number_of_steps,
          title: title
        }
      end
    end

    def number_of_steps
      @number_of_steps ||= @steps.count { |step| step.increment_step? }
    end
  end
end
