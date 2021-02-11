shared_examples_for "an incoming interaction" do
  context "when attention_needed_since value is empty" do
    it "updates the associated client" do
      expect { subject.save }
        .to change(subject.client, :attention_needed_since)
        .and change(subject.client, :first_unanswered_incoming_correspondence_at)
        .and change(subject.client, :last_incoming_interaction_at)
        .and change(subject.client, :last_interaction_at)
        .and change(subject.client, :updated_at)
    end
  end

  context "when attention_needed_since value is already set" do
    # ensure attention_needed_since is set on the client.
    before { subject.client.attention_needed_since = Time.now }

    it "updates the associated client, but does not change attention_needed_since" do
      expect { subject.save }
        .to not_change(subject.client, :attention_needed_since)
        .and change(subject.client, :first_unanswered_incoming_correspondence_at)
        .and change(subject.client, :last_incoming_interaction_at)
        .and change(subject.client, :last_interaction_at)
        .and change(subject.client, :updated_at)
    end
  end

  context "when first_unanswered_incoming_correspondence value is already set" do
    before { subject.client.first_unanswered_incoming_correspondence_at = Time.now }
    it "updates the associated client, but does not change the fuica value" do
      expect { subject.save }
        .to not_change(subject.client, :first_unanswered_incoming_correspondence_at)
        .and change(subject.client, :updated_at)
    end
  end
end

shared_examples_for "an internal interaction" do
  it "updates the associated client" do
    expect { subject.save }
      .to change(subject.client, :last_interaction_at)
      .and not_change(subject.client, :attention_needed_since)
      .and not_change(subject.client, :last_incoming_interaction_at)
      .and change(subject.client, :updated_at)
  end
end

shared_examples_for "an outgoing interaction" do
  # ensure attention_needed_since is set on the client so that we can test that it was cleared properly.
  before do
    subject.client.attention_needed_since = Time.now
    subject.client.first_unanswered_incoming_correspondence_at = Time.now
  end

  it "updates the associated client" do
    expect { subject.save }
      .to change(subject.client, :attention_needed_since).to(nil)
      .and change(subject.client, :first_unanswered_incoming_correspondence_at).to(nil)
      .and change(subject.client, :last_interaction_at)
      .and change(subject.client, :updated_at)
      .and not_change(subject.client, :last_incoming_interaction_at)
  end
end