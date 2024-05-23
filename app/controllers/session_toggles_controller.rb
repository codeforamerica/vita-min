class SessionTogglesController < ApplicationController
  layout "hub"
  include AccessControllable
  before_action :require_sign_in, if: -> { Rails.env.production? }

  def index
    @toggle_times = [
      {
        service_name: 'Get Your Refund',
        service_url: url_for(host: MultiTenantService.new(:gyr).host, controller: :session_toggles),
        times: [
          SessionToggleTime.new(name: 'Start of unique-links only intake', property: :start_of_unique_links_only_intake),
          SessionToggleTime.new(name: 'Start of open intake', property: :start_of_open_intake),
          SessionToggleTime.new(name: 'Tax deadline', property: :tax_deadline),
          SessionToggleTime.new(name: 'End of intake', property: :end_of_intake),
          SessionToggleTime.new(name: 'End of documents upload', property: :end_of_docs),
          SessionToggleTime.new(name: 'End of finishing in-progress intakes', property: :end_of_in_progress_intake),
          SessionToggleTime.new(name: 'End of login', property: :end_of_login),
        ]
      },
      {
        service_name: 'StateFile',
        service_url: url_for(host: MultiTenantService.new(:statefile).host, controller: :session_toggles),
        times: [
          SessionToggleTime.new(name: 'Start of open intake', property: :state_file_start_of_open_intake),
          SessionToggleTime.new(name: 'Withdrawal date deadline for New York', property: :state_file_withdrawal_date_deadline_ny),
          SessionToggleTime.new(name: 'End of new intakes', property: :state_file_end_of_new_intakes),
          SessionToggleTime.new(name: 'End of in-progress intakes', property: :state_file_end_of_in_progress_intakes),
        ]
      },
      {
        service_name: 'GetCTC',
        service_url: url_for(host: MultiTenantService.new(:ctc).host, controller: :session_toggles),
        times: [
          SessionToggleTime.new(name: 'Soft launch', property: :ctc_soft_launch),
          SessionToggleTime.new(name: 'Full launch', property: :ctc_full_launch),
          SessionToggleTime.new(name: 'EITC soft launch', property: :eitc_soft_launch),
          SessionToggleTime.new(name: 'EITC full launch', property: :eitc_full_launch),
          SessionToggleTime.new(name: 'End of intake', property: :ctc_end_of_intake),
          SessionToggleTime.new(name: 'End of read-write access', property: :ctc_end_of_read_write),
          SessionToggleTime.new(name: 'End of login', property: :ctc_end_of_login),
        ]
      }
    ]
    @toggle = SessionToggle.new(session, 'app_time')
  end

  def create
    @toggle = SessionToggle.new(session, 'app_time')
    if params[:clear]
      @toggle.clear
    else
      @toggle.value = params[:session_toggle][:value]
      @toggle.save
    end

    redirect_to action: :index
  end

  class SessionToggleTime
    attr_accessor :name

    def initialize(name:, property:)
      @name = name
      @property = property
    end

    def value
      Rails.configuration.send(@property)
    end

    def past?(app_time)
      value <= app_time
    end
  end
end
