shared_examples "email address validation" do |form_class|
  context "when the email is valid" do
    it "is valid" do

      form = form_class.new(
        form_object,
        {
          email_address: "stuff@things.net",
          email_address_confirmation: "stuff@things.net"
        }
      )

      expect(form).to be_valid
    end
  end

  context "when the email does not have a top level domain" do
    it "is not valid" do

      form = form_class.new(
        form_object,
        {
          email_address: "stuff@things",
          email_address_confirmation: "stuff@things"
        }
      )

      expect(form).not_to be_valid
      expect(form.errors[:email_address]).to be_present
    end
  end

  context "when there is whitespace mismatch with confirmation email" do
    it "is valid" do
      form = form_class.new(
        form_object,
        {
          email_address: "stuff@things.net",
          email_address_confirmation: " stuff@things.net "
        }
      )

      expect(form).to be_valid
    end
  end
end

