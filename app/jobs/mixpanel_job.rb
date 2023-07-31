class MixpanelJob < ApplicationJob
  def priority
    PRIORITY_LOW
  end

  def perform(distinct_id:, event_name:, data: {})
    MixpanelService.instance.run(distinct_id: distinct_id, event_name: event_name, data: data)
  end
end
