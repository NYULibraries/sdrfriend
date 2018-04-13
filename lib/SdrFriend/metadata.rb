require 'json'
require 'csv'
require 'SdrFriend/fda'

module SdrFriend
  class Metadata

    def self.row_to_rec(row, delimiter = "|")
      record = {}
      references = {}
      row.each do |term, value|
        case term
          when "dspace-internal-id"
            record["nyu_addl_dspace_s"] = value.to_s
          when "handle-identifier"
            record["dc_identifier_s"] = value.to_s
          when "title"
            record["dc_title_s"] = value.to_s
          when "description"
            record["dc_description_s"] = value.to_s
          when "rights"
            record["dc_rights_s"] = value.to_s
          when "ref:url"
            references["http://schema.org/url"] = value.to_s
          when "ref:download-url"
            references["http://schema.org/downloadUrl"] = value.to_s
          when "ref:wfs-endpoint"
            references["http://www.opengis.net/def/serviceType/ogc/wfs"] = value.to_s
          when "ref:wms-endpoint"
            references["http://www.opengis.net/def/serviceType/ogc/wms"] = value.to_s
          when "ref:documentation-url"
            references["http://lccn.loc.gov/sh85035852"] = value.to_s
          when "type"
            record["dc_type_s"] = value.to_s
          when "layer-geom-type"
            record["layer_geom_type_s"] = value.to_s
          when "layer-id"
            record["layer_id_s"] = value.to_s
          when "layer-slug"
            record["layer_slug_s"] = value.to_s
          when "layer-modified-date"
            record["layer_modified_dt"] = value.to_s
          when "format"
            record["dc_format_s"] = value.to_s
            record["nyu_addl_format_sm"] = [value.to_s]
          when "language"
            record["dc_language_s"] = value.to_s
          when "publisher"
            record["dc_publisher_s"] = value.to_s
          when "creators"
            record["dc_creator_sm"] = value.to_s.split(delimiter)
          when "subjects"
            record["dc_subject_sm"] = value.to_s.split(delimiter)
          when "issue-date"
            record["dct_issued_s"] = value.to_s
          when "is-part-of"
            record["dct_isPartOf_sm"] = value.to_s.split(delimiter)
          when "temporal-coverage"
            record["dct_temporal_sm"] = value.to_s.split(delimiter)
          when "spatial-subjects"
            record["dct_spatial_sm"] = value.to_s.split(delimiter)
          when "solr-geom"
            record["solr_geom"] = value.to_s
          when "solr-year"
            record["solr_year_i"] = value.to_i
          when "geoblacklight-version"
            record["geoblacklight_version"] = value.to_s
          when "source"
            record["dct_source_sm"] = value.to_s.split(delimiter)
          when "provenance"
            record["dct_provenance_s"] = value.to_s
          else
            #puts("error #{value}")
        end
      end
      references.each do |k,v|
        if v.empty?
          references.delete(k)
        end
      end
      record["dct_references_s"] = JSON.generate(references)
      return record.sort.to_h
    end

    def self.csv_to_collection(csv_table, delimiter="|")
      collection = []
      csv_table.each do |row|
        if row['row-type'] == 'entry'
          collection << row_to_rec(row)
        end
      end
      return collection
    end

    def self.record_to_row(json_record, delimiter="|")
      references = JSON.parse(json_record["dct_references_s"])
      row = {
          "row-type" => "entry",
          "dspace-internal-id" => json_record["nyu_addl_dspace_s"],
          "handle-identifier" => json_record["dc_identifier_s"],
          "title" => json_record["dc_title_s"],
          "description" => json_record["dc_description_s"],
          "rights" => json_record["dc_rights_s"],
          "ref:url" => references["http://schema.org/url"],
          "ref:download-url" => references["http://schema.org/downloadUrl"],
          "ref:wfs-endpoint" => references["http://www.opengis.net/def/serviceType/ogc/wfs"],
          "ref:wms-endpoint" => references["http://www.opengis.net/def/serviceType/ogc/wms"],
          "ref:documentation-url" => references["http://lccn.loc.gov/sh85035852"],
          "type" => json_record["dc_type_s"],
          "layer-geom-type" => json_record["layer_geom_type_s"],
          "layer-id" => json_record["layer_id_s"],
          "layer-slug" => json_record["layer_slug_s"],
          "layer-modified-date" => json_record["layer_modified_dt"],
          "format" => json_record["dc_format_s"],
          "language" => json_record["dc_language_s"],
          "publisher" => json_record["dc_publisher_s"],
          "creators" => nil,
          "subjects" => nil,
          "issue-date" => json_record["dct_issued_s"],
          "is-part-of" => nil,
          "temporal-coverage" => nil,
          "spatial-subjects" => nil,
          "solr-geom" => json_record["solr_geom"],
          "solr-year" => json_record["solr_year_i"],
          "geoblacklight-version" => json_record["geoblacklight_version"],
          "source" => nil,
          "provenance" => json_record["dct_provenance_s"]
      }



      unless json_record["dc_creator_sm"].nil?
        row["creators"] = json_record["dc_creator_sm"].join(delimiter)
      end

      unless json_record["dc_subject_sm"].nil?
        row["subjects"] = json_record["dc_subject_sm"].join(delimiter)
      end

      unless json_record["dct_isPartOf_sm"].nil?
        row["is-part-of"] = json_record["dct_isPartOf_sm"].join(delimiter)
      end

      unless json_record["dct_temporal_sm"].nil?
        row["temporal-coverage"] = json_record["dct_temporal_sm"].join(delimiter)
      end

      unless json_record["dct_spatial_sm"].nil?
        row["spatial-subjects"] = json_record["dct_spatial_sm"].join(delimiter)
      end

      unless json_record["dct_source_sm"].nil?
        row["source"] = json_record["dct_source_sm"].join(delimiter)
      end

      return row

    end

    def self.collection_to_csv(collection, delimiter="|")
      csv_rows = []
      collection.each do |record|
        row_hash = record_to_row(record, delimiter)
        csv_rows << CSV::Row.new(row_hash.keys, row_hash.values)
      end
      return CSV::Table.new(csv_rows)
    end

    def self.bitstream_hydrate(records)
      client = SdrFriend::Fda.new

      records.each do |record|
        add_dspace_id = false
        if record["nyu_addl_dspace_s"]
          id = record["nyu_addl_dspace_s"]
        elsif record["dc_identifier_s"]
          add_dspace_id = true
          id = record["dc_identifier_s"]
        else
          raise "Unable to determine a valid identifier for record."
        end

        fda_md = client.grab_item_metadata(id)
        if add_dspace_id
          record["nyu_addl_dspace_s"] = fda_md['id'].to_s
        end
        references = JSON.parse(record['dct_references_s'])

        fda_md['bitstreams'].each do |bs|
          if /^#{record['layer_slug_s'].gsub("-","_")}\./.match(bs['name'])
            references["http://schema.org/downloadUrl"] = SdrFriend::Fda.bitstream_url(bs['id'], bs['name'])
          elsif /^#{record['layer_slug_s'].gsub("-","_")}_doc\./.match(bs['name'])
            references["http://lccn.loc.gov/sh85035852"] = SdrFriend::Fda.bitstream_url(bs['id'], bs['name'])
          end

        end
        record['dct_references_s'] = JSON.generate(references)
      end

    end

    def self.alphabetize_keys(records)
      collection = []
      records.each do |record|
        collection << record.sort.to_h
      end
      return collection
    end



    private

    def csv_row_ordering
      return [
          "row-type",
          "dspace-internal-id",
          "handle-identifier",
          "title",
          "description",
          "rights",
          "ref:url",
          "ref:download-url",
          "ref:wfs-endpoint",
          "ref:wms-endpoint",
          "ref:documentation-url",
          "type",
          "layer-geom-type",
          "layer-id",
          "layer-slug",
          "layer-modified-date",
          "format",
          "language",
          "publisher",
          "creators",
          "subjects",
          "issue-date",
          "is-part-of",
          "temporal-coverage",
          "spatial-subjects",
          "solr-geom",
          "solr-year",
          "geoblacklight-version",
          "source",
          "provenance"
      ]
    end


  end
end
