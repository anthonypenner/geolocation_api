module Api
  module V1
    class GeolocationsController < ApplicationController
      rescue_from Faraday::Error, with: :handle_faraday_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from InvalidIpOrUrlError, with: :handle_invalid_ip_or_url

      def create
        result = GeolocationService.new.fetch(params[:ip_or_url])

        geolocation = GeoLocation.create!(
          ip: result['ip'],
          url: params[:ip_or_url],
          latitude: result['latitude'],
          longitude: result['longitude'],
          country: result['country_name'],
          city: result['city']
        )

        render json: GeolocationSerializer.new(geolocation).serializable_hash, status: :created
      end

      def show
        geolocation = find_geolocation
        render json: GeolocationSerializer.new(geolocation).serializable_hash
      end

      def destroy
        geolocation = find_geolocation
        geolocation.destroy
        head :no_content
      end

      private

      def find_geolocation
        GeoLocation.find_by(ip: params[:ip_or_url]) || GeoLocation.find_by!(url: params[:ip_or_url])
      rescue ActiveRecord::RecordNotFound
        raise
      end

      def handle_faraday_error(e)
        render json: { error: "Failed to fetch geolocation data: #{e.message}" }, status: :service_unavailable
      end

      def handle_not_found
        render json: { error: "Geolocation not found for: #{params[:ip_or_url]}" }, status: :not_found
      end

      def handle_invalid_ip_or_url(e)
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end