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

      def get_progress(controller)
        sections.lazy.map { |s| s.get_progress(controller) }.detect(&:present?)
      end
    end
  end
end
