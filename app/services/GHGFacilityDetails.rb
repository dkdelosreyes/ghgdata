require 'open-uri'
require 'net/http'

class GHGFacilityDetails
  GHGRPID   = 'GHGRPID'
  DATA_YEAR = 2022

  SUMMARY_URL    = "https://ghgdata.epa.gov/ghgp/service/facilityDetail/#{DATA_YEAR}?id=#{GHGRPID}&ds=E&et=&popup=true"
  DETAIL_XML_URL = "https://ghgdata.epa.gov/ghgp/service/xml/#{DATA_YEAR}?id=#{GHGRPID}&et=undefined"

  attr_reader :ghgrpid

  def initialize(id)
    @ghgrpid = id
  end

  def get_summary
    url  = SUMMARY_URL.gsub(GHGRPID, ghgrpid.to_s)
    html = fetch_html(url)

    return { error: "Error downloading information" } unless html
    
    tables = Nokogiri::HTML(html).css("#tabs-1 table")
    parse_summary(tables)
  
  rescue => e
    { error: "Error downloading information: #{e.message}" }
  end

  def get_details_filepath
    url = DETAIL_XML_URL.gsub(GHGRPID, ghgrpid.to_s)
    uri = URI(url)

    download_xml(uri)
  rescue => e
    { error: "Error downloading XML: #{e.message}" }
  end

  private

  def fetch_html(url)
    URI.open(url).read
  rescue StandardError => e
    puts "Error fetching HTML: #{e.message}"
    nil
  end

  def parse_summary(tables)
    data = { 
      ghgrpid:                  ghgrpid, 
      total_facility_emissions: nil, 
      data_year:                DATA_YEAR, 
      summary: { 
        emissions:              {}, 
        production_information: {}, 
        general_information:    {} 
      } 
    }

    tables.each_with_index do |table, index|
      
      if index.zero?
        data[:total_facility_emissions] = extract_emissions(table)
        next
      end

      table_label, group = get_table_title_and_group(table)

      is_general_info = group == :general_information
      table_data = get_table_data(table, is_general_info)

      if is_general_info
        data[:summary][group] = table_data
      else
        data[:summary][group][table_label] = table_data
      end
    end

    data
  end

  def extract_emissions(table)
    table.css('tr').at_css('td:nth-child(2)').text.strip.gsub(/\s+/, ' ').delete(",").to_i
  end

  def get_table_title_and_group(table)
    title_container = table.previous_element

    title = nil
    group = :general_information 

    with_table_title = title_container && title_container.name == 'div'
    if with_table_title
      title = title_container.text.strip.gsub(/\s+/, ' ')
      
      if title.downcase.start_with?("emission")
        group = :emissions
      elsif title.downcase.start_with?("information")
        group = :production_information
      end
    end

    [title, group]
  end

  def get_table_data(table, is_general_info = false)
    data = {}

    table.css('tr').each do |row|
      label, value = extract_row_data(row, is_general_info)
      next if label.blank?

      data[label] = value
    end

    data
  end

  def extract_row_data(row, is_general_info)
    col1 = row.at_css('td:nth-child(1)')
    col2 = row.at_css('td:nth-child(2)')

    if is_general_info && col2.blank?
      label, value = row.text.strip.split(':').map(&:strip)
      
    else
      label = col1 ? col1.text.strip.gsub(/\s+/, ' ') : nil
      return if label.blank?

      value = col2 ? col2.text.strip.gsub(/\s+/, ' ') : nil

      # Value is numeric
      if value.present? && value.include?(',') && value.delete(",").to_i != 0
        value = value.delete(",").to_i
      end
    end

    [label, value]
  end

  def download_xml(uri)
    file_path = Rails.root.join('tmp', "#{ghgrpid}.xml")

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)

      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          return { error: "Failed to download XML: #{response.code} #{response.message}" }
        end

        File.open(file_path, 'wb') do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end

        return file_path
      end
    end
  end
end