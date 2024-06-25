class GeolocationSerializer
  include JSONAPI::Serializer
  
  attributes :ip, :url, :latitude, :longitude, :country, :city
end
