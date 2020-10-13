class PublicPagesController < ApplicationController

  skip_before_action :check_maintenance_mode
  before_action :redirect_offseason_intake, only: [:diy_home]
  def include_analytics?
    true
  end

  def home; end

  def diy_home; end

  def other_options; end

  def maybe_ineligible; end

  def privacy_policy; end

  def about_us; end

  def maintenance; end

  def internal_server_error; end

  def page_not_found; end

  def tax_questions; end

  def stimulus_recommendation; end
end
