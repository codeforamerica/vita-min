require 'rails_helper'

class ExampleModel
  # This was copied from OutgoingEmail to have a real example, but not literally
  # tie to an existing model (which may change)
  def self.column_defaults
    {
      "id" => nil,
      "body" => "some body text",
      "client_id" => nil,
      "created_at" => nil,
      "mailgun_status" => "sending",
      "message_id" => nil,
      "sent_at" => nil,
      "subject" => nil,
      "to" => nil,
      "updated_at" => nil,
      "user_id" => nil
    }
  end
end

class SecondExampleModel
  # This was copied from OutgoingEmail to have a real example, but not literally
  # tie to an existing model (which may change)
  def self.column_defaults
    {
      "id" => nil,
      "body" => "some body text",
      "client_id" => nil,
      "created_at" => nil,
      "mailgun_status" => "sending",
      "message_id" => nil,
      "sent_at" => nil,
      "subject" => nil,
      "to" => nil,
      "updated_at" => nil,
      "user_id" => nil
    }
  end
end

class SymbolExampleForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include FormAttributes

  set_attributes_for :empty
  set_attributes_for :without_defaults, :attribute_one, :attribute_two
  set_attributes_for :with_defaults,
    :default_attribute_one,
    :default_attribute_two,
    :default_attribute_three,
    defaults: {
      default_attribute_one: 'foo',
      default_attribute_two: 'bar',
    }
end

class ModelExampleForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include FormAttributes

  set_attributes_for ExampleModel,
    :body,
    :client_id,
    :mailgun_status,
    defaults: {
      mailgun_status: "not_sent",
    }

  set_attributes_for SecondExampleModel,
    :body
end


RSpec.describe FormAttributes do
  describe "#set_attributes_for" do
    context "when passing a symbol" do
      subject { SymbolExampleForm.new }

      it 'should create an empty hash by default' do
        attributes = subject.attributes_for(:empty)
        expect(attributes).to be_a Hash
        expect(attributes).to be_empty
      end

      it 'should create initialize with nil if defaults are not passed' do
        attributes = subject.attributes_for(:without_defaults)
        expect(attributes).to match(attribute_one: nil, attribute_two: nil)
      end

      it 'should initialize with defaults when defaults are passed' do
        attributes = subject.attributes_for(:with_defaults)
        expect(attributes).to match(
          default_attribute_one: 'foo',
          default_attribute_two: 'bar',
          default_attribute_three: nil,
        )
      end

      it 'should create an hash for each symbol passed' do
        [:without_defaults, :empty, :with_defaults].each do |attribute|
          expect(subject.attributes_for(attribute)).to be_a Hash
        end
      end
    end

    context "when passing a model" do
      subject { ModelExampleForm.new }

      it 'should only create defaults where column defaults exist' do
        attributes = subject.attributes_for(ExampleModel)

        expect(attributes[:body]).to eq 'some body text'
        expect(subject.body).to eq 'some body text'

        expect(attributes[:client_id]).to be_nil
        expect(subject.client_id).to be_nil
      end

      it 'should not use column defaults when a defaults hash is specified' do
        expect(subject.mailgun_status).not_to eq 'sending'
        expect(subject.mailgun_status).to eq 'not_sent'
      end
    end
  end
end
