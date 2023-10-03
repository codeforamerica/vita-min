require "rails_helper"

RSpec.describe DependentsController do
  let(:intake) { create :intake }

  before { sign_in intake.client }

  describe "#index" do
    it "redirects to Questions::DependentsController" do
      get :index
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end

  describe "#create" do
    it "redirects to Questions::DependentsController" do
      post :create
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end

  describe "#update" do
    it "redirects to Questions::DependentsController" do
      put :update, params: { id: 123 }
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end

  describe "#new" do
    it "redirects to Questions::DependentsController" do
      get :new
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end

  describe "#edit" do
    it "redirects to Questions::DependentsController" do
      get :edit, params: { id: 123 }
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end

  describe "#destroy" do
    it "redirects to Questions::DependentsController" do
      delete :destroy, params: { id: 123 }
      expect(response).to redirect_to(Questions::DependentsController.to_path_helper(action: :index))
    end
  end
end
