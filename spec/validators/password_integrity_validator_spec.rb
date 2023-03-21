# frozen_string_literal: true
require "rails_helper"

class MockModel
  include ActiveModel::Validations
  attr_accessor :password, :email, :phone_number, :name

  validates_with PasswordIntegrityValidator, attributes: :password
end

describe PasswordIntegrityValidator do
  subject { MockModel.new }

  describe "#validate_each" do
    context "with an invalid password" do
      before do
        subject.password = "invalid"
      end

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end
    context "with a valid password" do
      before do
        subject.password = "aPr3tTEA_Complex"
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
