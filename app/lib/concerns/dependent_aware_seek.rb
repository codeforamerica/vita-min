module DependentAwareSeek
  extend ActiveSupport::Concern

  private

  def seek(list, &additional_check)
    list.detect do |controller_class|
      next if additional_check && !additional_check.call(controller_class)
      controller_class.show?(current_controller.visitor_record, current_controller.visitor_record&.dependents&.find_by_id(current_controller.params[:id]))
    end
  end
end
