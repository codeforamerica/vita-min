RSpec::Matchers.define_negated_matcher :not_change, :change

shared_examples_for "an incoming interaction" do
  it "updates the associated client" do
    expect { subject.save }
      .to change(subject.client, :attention_needed_since)
      .and change(subject.client, :last_incoming_interaction_at)
      .and change(subject.client, :last_interaction_at)
  end
end

shared_examples_for "an internal interaction" do
  it "updates the associated client" do
    expect { subject.save }
      .to not_change(subject.client, :attention_needed_since)
      .and not_change(subject.client, :last_incoming_interaction_at)
      .and change(subject.client, :last_interaction_at)
  end
end

shared_examples_for "an outgoing interaction" do
  # ensure attention_needed_since is set on the client so that we can test that it was cleared properly.
  before { subject.client.attention_needed_since = Time.now }

  it "updates the associated client" do
    expect { subject.save }
      .to change(subject.client, :attention_needed_since).to(nil)
      .and change(subject.client, :last_interaction_at)
      .and not_change(subject.client, :last_incoming_interaction_at)
  end
end