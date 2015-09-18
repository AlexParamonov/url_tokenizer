shared_context "real_data_context" do
  let(:expires_in) { 60 }

  def request_successful?(url)
    uri = URI.parse url
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.head(uri.request_uri).code == "200"
    end
  end

  it "is successful" do
    url_with_token = subject.call url, expires_in: expires_in
    expect(request_successful? url_with_token).to be_truthy
  end
end
