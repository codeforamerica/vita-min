module Navigation
  module StateFileBaseQuestionNavigationMixin

    def self.included(base)
      base.extend(ClassMethods)
    end

    def can_execute_step?(controller, prev_completed_step)
      return true if prev_completed_step.nil?
      step = get_step(controller)
      return !before?(step, prev_completed_step) if step.requires_completed.present?
      current_index = index_of_step(controller)
      return true if current_index.blank?
      completed_index = index_of_step(prev_completed_step)
      (current_index - 1) <= completed_index
    end

    def before?(a, b)
      a = index_of_step(a)
      b = index_of_step(b)
      return false if a.nil? || b.nil?
      a < b
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

    module ClassMethods
      def sections
        const_get(:SECTIONS)
      end

      def get_section(controller)
        sections.detect { |section| section.controllers.select { |c| c == controller }.present? }
      end

      def get_step(controller)
        sections.lazy.map(&:steps).detect { |s| s.controller == controller }
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
