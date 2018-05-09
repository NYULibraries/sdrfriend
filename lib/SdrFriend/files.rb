

module SdrFriend
  class Files

    def self.make_bitstream_folders(destination_path, folder_name_list)
      folder_name_list.each do |ls|
        path = destination_path + '/' + ls
        `mkdir -p #{path}`
      end
    end

    def self.zip_bitstream_folders(folder_location)
      entries = Dir.entries(folder_location).select {|entry| File.directory? File.join(folder_location,entry) and !(entry =='.' || entry == '..') }.select{ |x| SdrFriend::Fda.folder_fits_upload_format(x) }
      entries.each{ |entry| `cd #{folder_location}; zip -r #{entry}.zip #{entry}`}
    end

  end
end