require 'csv'
require 'json'
require 'figs'
require 'tempfile'

module SdrFriend
  class Fda
    def initialize(autoload = true)
      Figs.load
      @token = nil
      @handle_table = nil
      if autoload
        load_table
        authenticate
      end
    end

    def load_table
      @handle_table = grab_lookup_table(ENV["CSV_DSPACE_LOOKUP_TABLE_URL"])
    end

    def authenticate
      @token = grab_token(ENV["FDA_USER"], ENV["FDA_PASS"])
    end

    ## Authenticates with DSpace API
    def grab_token(username, password)
      cmd = `curl -X POST -H "Content-Type: application/json" -d '{"email":"#{username}","password":"#{password}"}' #{ENV["FDA_REST_ENDPOINT"]}/login --insecure -s`
      return cmd
    end

    ## Retrieves a handle -> dspace_id lookup table
    def grab_lookup_table(csv_url)
      cmd = `curl #{csv_url} -s`
      csv = cmd.gsub("\r","\n").split(/\n+/).map{ |x| x.split(",")}
      table = {}
      csv.each {|row| table[row[0]] = row[1]}
      return table
    end

    ## Converts between a handle and a dspace_id
    def translate_handle_to_dspace_id(handle)
      ## Three possible patterns:
      # http://hdl.handle.net/2451/12345
      # nyu_2451_12345
      # nyu-2451-12345
      if /^https?:\/\/hdl.handle.net\/\d{4}\/\d{5}$/.match(handle)
        return handle_to_dspace(handle.gsub(/^https?:\/\/hdl.handle.net\//, ""))
      elsif /^nyu-\d{4}-\d{5}$/.match(handle)
        return handle_to_dspace(handle.gsub("nyu-", "").gsub("-", "/"))
      elsif /^nyu_\d{4}_\d{5}$/.match(handle)
        return handle_to_dspace(handle.gsub("nyu_", "").gsub("_", "/"))
      else
        raise 'Handle given does not match known pattern!'
      end
    end

    def grab_item_metadata(identifier)
      dspace_id = identifier
      if is_handle?(identifier)
        dspace_id = translate_handle_to_dspace_id(identifier)
      end
      cmd = `curl -X GET -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/items/#{dspace_id}?expand=all --insecure -s`
      JSON.parse(cmd)
    end

    def is_handle?(input)
      if /^https?:\/\/hdl.handle.net\/\d{4}\/\d{5}$/.match(input)
        return true
      elsif /^nyu-\d{4}-\d{5}$/.match(input)
        return true
      elsif /^nyu_\d{4}_\d{5}$/.match(input)
        return true
      else
        return false
      end
    end

    ## "Mint" a new record with a Handle
    def create_container(collection, container = nil)
      active_container = container
      if active_container.nil?
        active_container = {
            "metadata": [
                {
                    "key": "dc.title",
                    "language": "en_US",
                    "value": "Empty Container Document"
                },
                {
                    "key": "dc.contributor.author",
                    "language": "en_US",
                    "value": "Data Services, Bobst Library"
                }
            ]
        }
      end
      cmd = `curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" -d '#{JSON.generate(active_container)}' #{ENV["FDA_REST_ENDPOINT"]}/collections/#{collection}/items --insecure -s`
      return JSON.parse(cmd)
    end

    ## Modify (add or replace) metadata elements on an FDA
    # record
    def alter_metadata(identifier, metadata_record)
      dspace_id = translate_handle_to_dspace_id(identifier)
      tempfile = Tempfile.new('alter-md')
      tempfile.write(JSON.generate(metadata_record))
      tempfile.close
      cmd = `curl -X PUT -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/items/#{dspace_id}/metadata --data @#{tempfile.path} --insecure -s`
      tempfile.unlink
      return cmd
    end

    def self.bitstream_url(bs_id, bs_name)
      return "https://archive.nyu.edu/retrieve/#{bs_id}/#{bs_name}"
    end


    def upload_bitstream(path_to_file, dspace_id = nil, force = false)
      ## Given a file, uploads to the appropriate FDA record if it hasn't already been uploaded
      filename = File.basename(path_to_file)
      if dspace_id.nil?
        ## Ascertain handle
        handle = filepath_to_handle(path_to_file)
        target_id = translate_handle_to_dspace_id(handle)
      else
        target_id = dspace_id
      end
      current_metadata = grab_item_metadata(target_id)
      if !bitstream_exists?(current_metadata, filename) || force
        return upload_bitstream_to_dspace(path_to_file, target_id)
      end
      raise "Could not upload bitstream"
    end

    def delete_bitstream(identifier, bitstream_filename)
      record = grab_item_metadata(identifier)
      bitstreams_to_delete = find_bitstream_ids(record, bitstream_filename)
      bitstreams_to_delete.each do |bs_id|
        puts "Deleting #{bs_id}..."
        _delete_bitstream(bs_id)
      end
    end

    def _delete_bitstream(bitstream_id)
      cmd = `curl -X DELETE -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/bitstreams/#{bitstream_id} --insecure -s`
      return cmd
    end

    def find_bitstream_ids(fda_metadata, bitstream_name)
      bitstream_ids = []
      fda_metadata['bitstreams'].each do |bitstream|
        if bitstream['name'] == bitstream_name
          bitstream_ids << bitstream['id']
        end
      end
      return bitstream_ids
    end

    def bitstream_exists?(fda_metadata, bitstream_name)
      fda_metadata['bitstreams'].each do |bitstream|
        if bitstream['name'] == bitstream_name
          return true
        end
      end
      return false
    end

    def grab_items(items, threads)


    end

    def standardize_handle_url(input)
      if /^http:\/\/hdl.handle.net\/\d{4}\/\d{5}$/.match(input)
        return input
      elsif /^nyu-\d{4}-\d{5}$/.match(input)
        components = input.split("-")
        return "http://hdl.handle.net/#{components[1]}/#{components[2]}"
      elsif /^nyu_\d{4}_\d{5}$/.match(input)
        components = input.split("_")
        return "http://hdl.handle.net/#{components[1]}/#{components[2]}"
      elsif /^\d{4}\/\d{5}$/.match(input)
        components = input.split("/")
        return "http://hdl.handle.net/#{components[0]}/#{components[1]}"
      else
        raise "No handle detected!"
      end
    end


    def upload_bitstream_to_dspace(path_to_file, dspace_id)
      filename = File.basename(path_to_file)
      cmd = `curl --data-binary "@#{path_to_file}" -H "Accept: application/json" -H "rest-dspace-token: #{@token}" #{ENV["FDA_REST_ENDPOINT"]}/items/#{dspace_id}/bitstreams?name=#{filename} --insecure`
      return JSON.parse(cmd)
    end

    def handle_to_dspace(handle)
      ## handle in pattern "2451/12345"
      return @handle_table["http://hdl.handle.net/#{handle}"]
    end

    def is_upload_candidate?(filepath)
      match = /nyu_\d{4}_\d{5}(_\w+)?\.\w+$/.match(filepath)
      if !match.nil?
        return true
      else
        return false
      end
    end

    def filepath_to_handle(filepath)
      match = /nyu_\d{4}_\d{5}/.match(File.basename(filepath))
      if !match.nil?
        return match[0]
      else
        raise 'No handle pattern detected in filename -- upload destination is ambiguous. (Filename must include "nyu_2451_12345" pattern!)'
      end
    end


  end
end