class AjaxMixpanelEventsController < ApplicationController
  def create
    return head :bad_request unless all_required_params_present?

    event_data = controller_and_path_data
    event_data = event_data.merge(event_params[:data]) if event_params[:data].present?

    send_mixpanel_event(
      event_name: event_params[:event_name],
      data: event_data
    )
  end

  private

  def event_params
    params.permit(:event_name, :full_path, :controller_action, data: {})
  end

  def all_required_params_present?
    [:event_name, :full_path, :controller_action].all? { |key| event_params[key].present? }
  end

  def controller_and_path_data
    controller, action = event_params[:controller_action].split("#", 2)
    {
      full_path: event_params[:full_path],
      path: URI(event_params[:full_path]).path,
      controller_action: event_params[:controller_action],
      controller_action_name: action,
      controller_name: controller.sub("Controller", ""),
    }
  end
end