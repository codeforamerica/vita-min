module Navigation
  module StateFileBaseQuestionNavigationMixin

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def sections
        const_get(:SECTIONS)
      end

      def get_section(controller)
        sections.detect { |section| section.controllers.select { |c| c == controller }}
      end

      def number_of_steps
        sections.count do |section|
          section.increment_step?
        end
      end

      def get_progress(controller)
        index = 0
        step = nil
        section = sections.find do |section|
          step = section.steps.detect { |s| s.controller == controller }
          if step.present?
            true
          else
            index += 1 if section.increment_step?
            false
          end
        end
        return if section.nil? || !step.show_steps?
        {
          title: I18n.t(section.title),
          step_number: index,
          number_of_steps: number_of_steps
        }
      end
    end
  end
end
