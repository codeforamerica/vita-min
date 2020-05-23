class ZendeskController < ApplicationController
  skip_before_action :check_at_capacity
  
  def sign_in
  end
end
