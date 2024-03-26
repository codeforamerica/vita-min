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
        sections.detect { |section| section.controllers.select { |c| c == controller }.present? }
      end

      def get_step(controller)
        sections.map(&:steps).flatten.detect { |s| s.controller == controller }
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

      def can_execute_step?(controller, last_completed_step)
        return true if last_completed_step.nil?
        step_ = get_step(controller)
        current_index = index_of_step(controller)
        return true if current_index.blank?
        require_completed_index = if step_.requires_completed.present?
          index_of_step(step_.requires_completed)
        else
          current_index - 1
        end
        completed_index = index_of_step(last_completed_step)

        if completed_index < require_completed_index
          binding.pry
        end
        completed_index >= require_completed_index
      end

      def index_of_step(controller)
        controllers.index(to_controller(controller))
      end

      def to_controller(controller)
        if controller.is_a? String
          # Cant use Rails.application.routes.recognize_path due to domain constraint
          controller_name = controller.split('/')[-1].gsub("-", "_").camelize
          controller = "StateFile::Questions::#{controller_name}Controller".constantize
        end
        controller
      end
    end
  end
end
