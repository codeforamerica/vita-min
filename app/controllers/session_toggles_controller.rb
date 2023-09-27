class SessionTogglesController < ApplicationController
  layout "hub"
  include AccessControllable
  before_action :require_sign_in, if: -> { Rails.env.production? }

  def index
    @gyr_times = [
      SessionToggleTime.new(name: 'Start of unique-links only intake', property: :start_of_unique_links_only_intake),
      SessionToggleTime.new(name: 'Start of open intake', property: :start_of_open_intake),
      SessionToggleTime.new(name: 'End of intake', property: :end_of_intake),
      SessionToggleTime.new(name: 'End of documents upload', property: :end_of_docs),
      SessionToggleTime.new(name: 'End of login', property: :end_of_login),
    ]
    @ctc_times = [
      SessionToggleTime.new(name: 'Soft launch', property: :ctc_soft_launch),
      SessionToggleTime.new(name: 'Full launch', property: :ctc_full_launch),
      SessionToggleTime.new(name: 'EITC soft launch', property: :eitc_soft_launch),
      SessionToggleTime.new(name: 'EITC full launch', property: :eitc_full_launch),
      SessionToggleTime.new(name: 'End of intake', property: :ctc_end_of_intake),
      SessionToggleTime.new(name: 'End of read-write access', property: :ctc_end_of_read_write),
      SessionToggleTime.new(name: 'End of login', property: :ctc_end_of_login),
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
