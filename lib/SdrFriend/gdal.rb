module SdrFriend
  class Gdal

    def self.find_shapefile_extent(shapefile_path)
      cmd = `ogrinfo -ro -so -al #{shapefile_path} | grep Extent`
      coords = cmd.scan(/-?\d{1,3}\.\d*/)
      return coords
    end

    def self.shapefile_to_solr_geom(shapefile_path)
      coords = Gdal.find_shapefile_extent(shapefile_path)
      raise "Invalid geometry" unless coords.count == 4
      return SdrFriend::Metadata.create_solr_geom(coords[0], coords[2], coords[3], coords[1])
    end

    # def self.shapefile_to_wgs84shp(input_shapefile_path, output_shapefile_path, verbose=true)
    #   if verbose
    #     puts "Beginning conversion from:\n\t#{input_shapefile_path}\nto\n\t#{output_shapefile_path}"
    #   end
    #   result = `ogr2ogr -t_srs EPSG:4326 "#{output_shapefile_path}" "#{input_shapefile_path}"`
    #   return result
    # end

  end
end