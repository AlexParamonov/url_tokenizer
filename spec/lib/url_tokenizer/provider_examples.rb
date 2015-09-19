shared_examples_for :provider do
  it 'requires the key' do
    expect do
      described_class.new
    end.to raise_error ArgumentError

    expect do
      described_class.new key
    end.not_to raise_error
  end

  it 'accepts provider options' do
    expect do
      described_class.new key, foo: :bar
    end.not_to raise_error
  end

  it 'responds to #call' do
    expect(subject).to respond_to :call
  end

  describe "#call" do
    it 'requires the url' do
      expect do
        subject.call
      end.to raise_error ArgumentError

      expect do
        subject.call 'http://example.com'
      end.not_to raise_error
    end

    it 'accepts provider options' do
      expect do
        subject.call 'http://example.com', foo: :bar
      end.not_to raise_error
    end
  end
end
