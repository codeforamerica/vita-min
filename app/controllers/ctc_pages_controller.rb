class CtcPagesController < ApplicationController
  def root
    render html: "Welcome to a CTC-only page"
  end
end
