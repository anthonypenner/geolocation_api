require 'rails_helper'
require 'faraday'

RSpec.describe "Api::V1::Geolocations", type: :request do
  let(:valid_headers) { {} }
  let(:valid_ip) { "8.8.8.8" }
  let(:valid_url) { "www.example.com" }
  let(:valid_attributes) {
    {
      ip: valid_ip,
      latitude: 37.751,
      longitude: -97.822,
      country: "United States",
      city: "Ashburn"
    }
  }
  let(:invalid_ip) { "999.999.999.999" }
  let(:invalid_url) { "invalid_url" }
  let(:empty_url) { "" }
  let(:url_with_spaces) { "invalid url" }
  let(:url_with_special_characters) { "invalid!url" }

  describe "POST /api/v1/geolocations" do
    context "with valid parameters" do
      it "creates a new GeoLocation" do
        mock_response = double(
          success?: true,
          body: JSON.generate(valid_attributes)
        )
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(mock_response)

        expect {
          post api_v1_geolocations_url,
               params: { ip_or_url: valid_ip }, headers: valid_headers, as: :json
        }.to change(GeoLocation, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['ip']).to eq(valid_ip)
      end

      it "creates a new GeoLocation with valid URL" do
        mock_response = double(
          success?: true,
          body: JSON.generate(valid_attributes)
        )
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(mock_response)

        expect {
          post api_v1_geolocations_url,
               params: { ip_or_url: valid_url }, headers: valid_headers, as: :json
        }.to change(GeoLocation, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for invalid IP" do
        allow_any_instance_of(GeolocationService).to receive(:fetch).and_raise(InvalidIpOrUrlError.new("Invalid IP/URL format"))

        post api_v1_geolocations_url,
             params: { ip_or_url: invalid_ip }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders a JSON response with errors for invalid URL" do
        allow_any_instance_of(GeolocationService).to receive(:fetch).and_raise(InvalidIpOrUrlError.new("Invalid IP/URL format"))

        post api_v1_geolocations_url,
             params: { ip_or_url: invalid_url }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders a JSON response with errors for empty URL" do
        allow_any_instance_of(GeolocationService).to receive(:fetch).and_raise(InvalidIpOrUrlError.new("Invalid IP/URL format"))

        post api_v1_geolocations_url,
             params: { ip_or_url: empty_url }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders a JSON response with errors for URL with spaces" do
        allow_any_instance_of(GeolocationService).to receive(:fetch).and_raise(InvalidIpOrUrlError.new("Invalid IP/URL format"))

        post api_v1_geolocations_url,
             params: { ip_or_url: url_with_spaces }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders a JSON response with errors for URL with special characters" do
        allow_any_instance_of(GeolocationService).to receive(:fetch).and_raise(InvalidIpOrUrlError.new("Invalid IP/URL format"))

        post api_v1_geolocations_url,
             params: { ip_or_url: url_with_special_characters }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "GET /api/v1/geolocations/:ip_or_url" do
    it "renders a successful response" do
      geolocation = GeoLocation.create!(valid_attributes.merge(ip: valid_ip))
      get api_v1_geolocation_path(geolocation.ip), headers: valid_headers, as: :json
      expect(response).to be_successful
    end

    it "renders a not found response for non-existent IP" do
      get api_v1_geolocation_path(invalid_ip), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "renders a not found response for non-existent URL" do
      get api_v1_geolocation_path(invalid_url), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/geolocations/:ip_or_url" do
    it "destroys the requested geolocation" do
      geolocation = GeoLocation.create!(valid_attributes.merge(ip: valid_ip))
      expect {
        delete api_v1_geolocation_path(geolocation.ip), headers: valid_headers, as: :json
      }.to change(GeoLocation, :count).by(-1)
    end

    it "renders a not found response for non-existent IP" do
      delete api_v1_geolocation_path(invalid_ip), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "renders a not found response for non-existent URL" do
      delete api_v1_geolocation_path(invalid_url), headers: valid_headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "Error Handling" do
    it "handles Faraday connection errors" do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("Connection failed"))

      post api_v1_geolocations_url,
           params: { ip_or_url: valid_ip }, headers: valid_headers, as: :json

      expect(response).to have_http_status(:service_unavailable)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to include("Failed to fetch geolocation data")
    end
  end
end