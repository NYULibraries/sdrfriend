require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "SdrFriend/fda"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :fda do

  desc 'View all current metadata for an FDA item -- identifier can be handle or dspace id'
  task :get, :identifier do |t, args|
    client = SdrFriend::Fda.new
    puts JSON.generate(client.grab_item_metadata(args[:identifier]))
  end

  desc 'Add a single bitstream; <identifier> argument optional IF handle can be extracted from filename'
  task :addbit, :file_path, :identifier do |t, args|
    client = SdrFriend::Fda.new
    puts JSON.generate(client.upload_bitstream(args[:file_path], args[:identifier]))
  end

  desc 'For an FDA record, delete all bitstreams with a given name'
  task :delbit, :identifier, :filename do |t, args|
    client = SdrFriend::Fda.new
    puts client.delete_bitstream(args[:identifier], args[:filename])
  end

  desc 'Translate a handle into a dspace internal id'
  task :translate, :handle do |t, args|
    client = SdrFriend::Fda.new
    puts client.translate_handle_to_dspace_id(args[:handle])
  end

  desc 'Create a SINGLE container record / "mint" a new handle; collection should be "public" or "restricted"'
  task :mint, :collection do |t, args|
    client = SdrFriend::Fda.new
    collection = nil
    if !args[:collection].nil?
      if args[:collection].downcase == "public"
        collection = 651
      elsif args[:collection].downcase == "restricted"
        collection = 652
      else
        raise "Unable to detect a valid collection name"
      end
      puts JSON.generate(client.create_container(collection))
    else
      raise "Unable to detect a valid collection name"
    end

  end




end


namespace :metadata do

  desc "Add FDA bitstream URLs to CSV"
  task :biturl, :csv_input, :csv_output do |t, args|

  end

  desc "Convert CSV to single JSON record collection file"
  task :csv_to_json, :csv_input, :csv_output do |t, args|

  end

  desc "Split-out JSON record collection file into multiple individual geoblacklight.json files"
  task :split, :json_input, :destination_path do |t, args|

  end

  desc "Create a blank template CSV for collection"
  task :template, :csv_output do |t, args|

  end



end