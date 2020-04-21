class PublicPagesController < ApplicationController
  skip_before_action :check_maintenance_mode

  def include_google_analytics?
    true
  end

  def home; end

  def other_options; end

  def maybe_ineligible; end

  def privacy_policy; end

  def about_us; end

  def maintenance; end
end
