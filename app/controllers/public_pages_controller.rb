class PublicPagesController < ApplicationController
  def include_google_analytics?
    true
  end

  def home; end

  def other_options; end

  def maybe_ineligible; end

  def privacy_policy; end

  def about_us; end
end