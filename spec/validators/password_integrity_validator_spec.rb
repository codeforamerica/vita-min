# frozen_string_literal: true
require "rails_helper"

class MockModel
  include ActiveModel::Validations
  attr_accessor :password, :email, :phone_number, :name

  validates_with PasswordIntegrityValidator, attributes: :password

  def admin?
    @admin || false
  end
end

describe PasswordIntegrityValidator do
  subject { MockModel.new }

  describe "#validate_each" do
    context "with an invalid password" do
      it "is not valid" do
        subject.password = "InvalidPha"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to include(I18n.t("errors.attributes.password.insecure"))
      end

      it "is not valid if it uses a commonly used password" do
        subject.password = "password123"
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to include(I18n.t("errors.attributes.password.insecure"))
      end

      it "is not valid for overly long passwords" do
        subject.password = "fake".ljust(129, "fake")
        expect(subject).not_to be_valid
        expect(subject.errors[:password]).to include(I18n.t("errors.attributes.password.incorrect_size"))
      end

       it "is not valid for too short passwords" do
         subject.password = "fake"
         expect(subject).not_to be_valid
         expect(subject.errors[:password]).to include(I18n.t("errors.attributes.password.incorrect_size"))
       end
    end

    context "with a valid password" do
      before do
        subject.password = "Strong_Passphrase3"
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
