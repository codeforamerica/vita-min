module Navigation
  class StateFileBaseQuestionNavigation
    class << self

      def navigation_class_from_state_code(state_code)
        unless StateFile::StateInformationService::STATES_INFO.key?(state_code)
          raise StandardError state_code
        end
        "Navigation::StateFile#{state_code.to_s.titleize}QuestionNavigation".constantize
      end

      def sections
        const_get(:SECTIONS)
      end

      def get_section(controller)
        sections.detect { |section| section.controllers.select { |c| c == controller }.present? }
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
