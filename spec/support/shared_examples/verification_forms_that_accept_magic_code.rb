shared_examples :a_verification_form_that_accepts_the_magic_code do
  let(:verification_code) { '000000' }
  let(:params) do
    {
      verification_code: verification_code
    }
  end

  context 'when the magic code is allowed and the code is 000000' do
    before do
      allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(true)
    end

    it 'is valid' do
      expect(form).to be_valid
    end
  end

  context 'when the magic code is allowed but the code is incorrect' do
    let(:verification_code) { '123000' }
    before do
      allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(true)
    end

    it 'is not valid' do
      expect(form).not_to be_valid
    end
  end

  context 'when the magic code is not allowed and the code is incorrect' do
    before do
      allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(false)
    end

    it 'is not valid' do
      expect(form).not_to be_valid
    end
  end
end
