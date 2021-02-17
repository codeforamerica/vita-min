require "rails_helper"

RSpec.describe FormAttributes do
  context "with a fake model" do
    let(:fake_model) do
      Class.new(ActiveRecord::Base) do
        def self.model_name
          "ExampleModel"
        end
      end
    end

    before do
      stub_const("ExampleModel", fake_model)
    end

    context "when included into a validatable form class" do
      let(:form_class) do
        Class.new do
          include ActiveModel::Model
          include ActiveModel::AttributeAssignment
          include ActiveModel::Validations::Callbacks
          include FormAttributes

          set_attributes_for :example_model, :attrib1, :attrib2
        end
      end

      describe ".attribute_names" do
        it "stores the list of attributes" do
          expect(form_class.attribute_names).to eq([:attrib1, :attrib2])
        end
      end

      describe "accessors" do
        it "creates an accessor for each attribute" do
          expect(form_class.new.attrib1).to be_nil
          expect(form_class.new.attrib2).to be_nil
        end
      end

      describe "validation" do
        context "whitespace trimming" do
          let(:form_class) do
            Class.new do
              include ActiveModel::Model
              include ActiveModel::AttributeAssignment
              include ActiveModel::Validations::Callbacks
              include FormAttributes

              set_attributes_for :example_model, :attrib1
              validates :attrib1, inclusion: ["data"]
            end
          end

          it "removes whitespace from values before validation" do
            form = form_class.new
            form.attrib1 = "data "
            expect(form).to be_valid
            expect(form.attrib1).to eq("data")
          end
        end

        context "enum validation" do
          context "with a model w/ enums" do
            let(:fake_model) do
              Class.new(ActiveRecord::Base) do
                def self.model_name
                  "ExampleModel"
                end

                enum attrib1: { valid_option: 0 }
              end
            end

            let(:form_class) do
              Class.new do
                include ActiveModel::Model
                include ActiveModel::AttributeAssignment
                include ActiveModel::Validations::Callbacks
                include FormAttributes

                set_attributes_for :example_model, :attrib1
              end
            end

            it "allows enum to be missing" do
              form = form_class.new({ attrib1: nil })
              expect(form).to be_valid
            end

            it "allows valid enum values to pass through" do
              form = form_class.new
              form.attributes = { attrib1: "valid_option" }
              expect(form).to be_valid
            end

            it "removes invalid enum values" do
              form = form_class.new
              form.attributes = {attrib1: "invalid_option"}
              expect(form).not_to be_valid
            end
          end
        end
      end
    end
  end
end
