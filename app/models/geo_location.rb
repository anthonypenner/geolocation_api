class GeoLocation < ApplicationRecord
  validates :ip, presence: true, uniqueness: true
  validates :url, uniqueness: true, allow_nil: true
end
