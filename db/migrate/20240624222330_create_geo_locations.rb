class CreateGeoLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :geo_locations do |t|
      t.string :ip
      t.string :url
      t.float :latitude
      t.float :longitude
      t.string :country
      t.string :city

      t.timestamps
    end
  end
end
