require "rails_helper"

RSpec.describe Hub::NotificationSettingsForm do
  let(:user) {
    create :user,
           new_client_message_notification: "yes",
           client_assignments_notification: "yes",
           document_upload_notification: "yes",
           tagged_in_note_notification: "yes",
           signed_8879_notification: "yes"
  }
  let(:base_form_attributes) do
    {
      new_client_message_notification: "yes",
      client_assignments_notification: "yes",
      document_upload_notification: "yes",
      tagged_in_note_notification: "yes",
      signed_8879_notification: "yes"
    }
  end

  describe "#initialize" do
    context "when params are empty" do
      it "loads attributes from user" do
        form = described_class.new(user)

        expect(form.new_client_message_notification).to eq "yes"
        expect(form.client_assignments_notification).to eq "yes"
        expect(form.document_upload_notification).to eq "yes"
        expect(form.tagged_in_note_notification).to eq "yes"
        expect(form.signed_8879_notification).to eq "yes"
        expect(form.unsubscribe_all).to be false
      end
    end

    context "when params are provided" do
      let(:form_attributes) do
        {
          new_client_message_notification: "no",
          client_assignments_notification: "no",
          document_upload_notification: "no",
          tagged_in_note_notification: "no",
          signed_8879_notification: "no"
        }
      end

      it "uses provided params instead of loading from user" do
        form = described_class.new(user, form_attributes)

        expect(form.new_client_message_notification).to eq "no"
        expect(form.client_assignments_notification).to eq "no"
        expect(form.document_upload_notification).to eq "no"
        expect(form.tagged_in_note_notification).to eq "no"
        expect(form.signed_8879_notification).to eq "no"
      end
    end
  end


  describe "#load_from_user" do
    context "when user has all notifications enabled" do
      it "sets unsubscribe_all to false" do
        form = described_class.new(user)

        expect(form.unsubscribe_all).to be false
      end
    end

    context "when user has all notifications disabled" do
      let(:user) {
        create :user,
               new_client_message_notification: "no",
               client_assignments_notification: "no",
               document_upload_notification: "no",
               tagged_in_note_notification: "no",
               signed_8879_notification: "no"
      }

      it "sets unsubscribe_all to true" do
        form = described_class.new(user)

        expect(form.unsubscribe_all).to be true
      end
    end

    context "when user has mixed notification settings" do
      let(:user) {
        create :user,
               new_client_message_notification: "yes",
               client_assignments_notification: "no",
               document_upload_notification: "yes",
               tagged_in_note_notification: "yes",
               signed_8879_notification: "yes"
      }

      it "sets unsubscribe_all to false" do
        form = described_class.new(user)

        expect(form.unsubscribe_all).to be false
      end
    end
  end

  describe "#save" do
    context "with valid notification preferences" do
      let(:form_attributes) do
        base_form_attributes.merge(
          new_client_message_notification: "no",
          client_assignments_notification: "yes",
          document_upload_notification: "yes",
          tagged_in_note_notification: "yes",
          signed_8879_notification: "yes"
        )
      end

      it "updates user attributes and saves" do
        form = described_class.new(user, form_attributes)
        expect(form).to be_valid
        result = form.save
        expect(result).to be true
        user.reload

        expect(user.new_client_message_notification).to eq "no"
        expect(user.client_assignments_notification).to eq "yes"
        expect(user.document_upload_notification).to eq "yes"
        expect(user.tagged_in_note_notification).to eq "yes"
        expect(user.signed_8879_notification).to eq "yes"
      end
    end

    context "when unsubscribe_all is selected" do
      let(:form_attributes) do
        base_form_attributes.merge(unsubscribe_all: "yes")
      end

      it "sets all notifications to 'no' and saves" do
        form = described_class.new(user, form_attributes)
        expect(form).to be_valid
        result = form.save
        expect(result).to be true
        user.reload

        expect(user.new_client_message_notification).to eq "no"
        expect(user.client_assignments_notification).to eq "no"
        expect(user.document_upload_notification).to eq "no"
        expect(user.tagged_in_note_notification).to eq "no"
        expect(user.signed_8879_notification).to eq "no"
      end
    end

    context "with invalid form (no notifications selected)" do
      let(:form_attributes) do
        {
          new_client_message_notification: "no",
          client_assignments_notification: "no",
          document_upload_notification: "no",
          tagged_in_note_notification: "no",
          signed_8879_notification: "no",
          unsubscribe_all: "no"
        }
      end

      it "returns false and does not save" do
        form = described_class.new(user, form_attributes)
        expect(form).not_to be_valid
        result = form.save
        expect(result).to be false
      end
    end
  end

  describe "#notification_selected" do
    context "when at least one notification is selected" do
      let(:form_attributes) do
        {
          new_client_message_notification: "yes",
          client_assignments_notification: "no",
          document_upload_notification: "no",
          tagged_in_note_notification: "no",
          signed_8879_notification: "no"
        }
      end

      it "is valid" do
        form = described_class.new(user, form_attributes)
        expect(form).to be_valid
      end
    end

    context "when unsubscribe_all is selected" do
      let(:form_attributes) do
        {
          new_client_message_notification: "no",
          client_assignments_notification: "no",
          document_upload_notification: "no",
          tagged_in_note_notification: "no",
          signed_8879_notification: "no",
          unsubscribe_all: "yes"
        }
      end

      it "is valid" do
        form = described_class.new(user, form_attributes)
        expect(form).to be_valid
      end
    end

    context "when no notifications are selected and unsubscribe_all is not selected" do
      let(:form_attributes) do
        {
          new_client_message_notification: "no",
          client_assignments_notification: "no",
          document_upload_notification: "no",
          tagged_in_note_notification: "no",
          signed_8879_notification: "no",
          unsubscribe_all: "no"
        }
      end

      it "adds a base error" do
        form = described_class.new(user, form_attributes)
        expect(form).not_to be_valid
        expect(form.errors[:base]).to include(I18n.t('hub.users.profile.error'))
      end
    end
  end

  describe "#process_unsubscribe_all" do
    context "when unsubscribe_all is 'yes'" do
      let(:form_attributes) do
        base_form_attributes.merge(unsubscribe_all: "yes")
      end

      it "sets all notification preferences to 'no' before save" do
        form = described_class.new(user, form_attributes)
        form.save

        expect(form.new_client_message_notification).to eq "no"
        expect(form.client_assignments_notification).to eq "no"
        expect(form.document_upload_notification).to eq "no"
        expect(form.tagged_in_note_notification).to eq "no"
        expect(form.signed_8879_notification).to eq "no"
      end
    end

    context "when unsubscribe_all is not 'yes'" do
      let(:form_attributes) do
        base_form_attributes.merge(
          new_client_message_notification: "no",
          unsubscribe_all: "no"
        )
      end

      it "does not change notification preferences" do
        form = described_class.new(user, form_attributes)
        form.save

        expect(form.new_client_message_notification).to eq "no"
        expect(form.client_assignments_notification).to eq "yes"
        expect(form.document_upload_notification).to eq "yes"
        expect(form.tagged_in_note_notification).to eq "yes"
        expect(form.signed_8879_notification).to eq "yes"
      end
    end
  end

  describe "#notification_attributes" do
    let(:form_attributes) do
      {
        new_client_message_notification: "no",
        client_assignments_notification: "yes",
        document_upload_notification: "no",
        tagged_in_note_notification: "no",
        signed_8879_notification: "no"
      }
    end

    it "returns the correct notification attributes hash" do
      form = described_class.new(user, form_attributes)

      expected_attributes = {
        new_client_message_notification: "no",
        client_assignments_notification: "yes",
        document_upload_notification: "no",
        tagged_in_note_notification: "no",
        signed_8879_notification: "no"
      }

      expect(form.notification_attributes).to eq expected_attributes
    end
  end

  describe ".permitted_params" do
    it "returns the correct permitted parameters" do
      expected_params = [:new_client_message_notification, :client_assignments_notification, :document_upload_notification, :tagged_in_note_notification, :signed_8879_notification, :unsubscribe_all]

      expect(described_class.permitted_params).to eq expected_params
    end
  end
end