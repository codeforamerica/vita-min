# frozen_string_literal: true
require "rails_helper"

describe PasswordStrengthValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      attr_accessor :password, :email, :phone_number, :name, :admin

      validates_with PasswordStrengthValidator, attributes: :password

      def initialize(password:, admin:)
        @password = password
        @admin = admin
      end

      def admin?
        @admin
      end
    end
  end

  subject { @validatable.new(password: password, admin: admin) }

  describe "#validate_each" do
    context "with a non-admin user" do
      let(:admin) { false }

      context "with a valid password" do
        let(:password) { "Strong_Passphrase3" }

        it "is valid" do
          expect(subject).to be_valid
        end
      end

      context "with an commonly used password" do
        let(:password) { "password123" }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:password]).to include(I18n.t("errors.attributes.password.insecure"))
        end
      end
    end

    context "with an admin" do
      let(:admin) { true }

      context "with a commonly used password" do
        let(:password) { "password123" }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end
  end
end
