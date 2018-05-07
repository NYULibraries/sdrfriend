RSpec.describe SdrFriend::Gdal do


  describe "#find_shapefile_extent" do
    it "returns coordinates for a fixture Shapefile" do
      expect( SdrFriend::Gdal.find_shapefile_extent("spec/fixtures/shapefiles/UAE-livestock/nyu_2451_UAE_livestock_12-15.shp") ).to eq(["51.499588", "22.497065", "56.381805", "26.078848"])
    end
    it "returns empty array for non-existing Shapefile" do
      expect( SdrFriend::Gdal.find_shapefile_extent("spec") ).to eq([])
    end

  end

  describe "#shapefile_to_solr_geom" do
    it "returns Solr ENVELOPE syntax for a fixture Shapefile" do
      expect(SdrFriend::Gdal.shapefile_to_solr_geom("spec/fixtures/shapefiles/UAE-livestock/nyu_2451_UAE_livestock_12-15.shp")).to eq( "ENVELOPE(51.499588, 56.381805, 26.078848, 22.497065)" )
    end
    it "throws an error when it can't create a Solr ENVELOPE" do
      expect {SdrFriend::Gdal.shapefile_to_solr_geom("spec")}.to raise_error(RuntimeError)
    end
  end

end
