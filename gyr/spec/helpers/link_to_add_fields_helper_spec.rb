require "rails_helper"
require 'action_view/helpers/form_helper'

class FakeForm < Form
  def initialize(intake, params={})
    @intake = intake
    super(params)
  end

  def association
    @intake.dependents
  end
end

describe LinkToAddFieldsHelper do
  before do
    form_for fake_form, url: "/", builder: VitaMinFormBuilder do |f|
      @form = f
    end
    allow(Dependent).to receive(:new)
  end

  let(:partial) { "shared/test_partial" }
  let(:fake_form) { FakeForm.new(create(:intake)) }
  let(:result) { helper.link_to_add_fields("Add new association", @form, :association, partial: partial) }
  describe "#link_to_add_fields" do
    it "creates a link with the provided link text" do
      expect(result).to include("Add new association")
    end

    it "instantiates a new object for the association" do
      result
      expect(Dependent).to have_received(:new)
    end
  end
end