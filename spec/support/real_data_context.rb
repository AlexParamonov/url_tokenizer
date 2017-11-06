shared_context "real_data_context" do
  let(:expires_in) { 60 }

  def request_successful?(url)
    uri = URI.parse url
    response = Net::HTTP.get_response(uri)

    response.code == "200"
  end

  it "is successful" do
    url_with_token = subject.call url, expires_in: expires_in
    expect(request_successful? url_with_token).to be_truthy
  end

  describe "with outdated token" do
    it "is unsuccessful" do
      url_with_token = subject.call url, expires_in: -5
      expect(request_successful? url_with_token).not_to be_truthy
    end
  end
end
