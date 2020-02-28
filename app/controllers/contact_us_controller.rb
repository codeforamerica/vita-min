class ContactUsController < ApplicationController
  def new
    @form = ContactUsForm.new
  end

  def create
    # TODO: Save the form
  end
end
