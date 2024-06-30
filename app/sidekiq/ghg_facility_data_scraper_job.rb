class GhgFacilityDataScraperJob
  include Sidekiq::Job

  def perform
    Facility.select(:id, :ghgrpid).find_each do |facility|
      api         = GHGFacilityDetails.new(facility.ghgrpid)
      api_summary = api.get_summary
      next if api_summary[:error].present?

      Summary.transaction do
        summary = find_or_create_summary(facility, api_summary)

        update_emissions(summary, api_summary[:summary][:emissions])
        update_production_information(summary, api_summary[:summary][:production_information])
        update_general_information(summary, api_summary[:summary][:general_information])
        attach_details_file(summary, api, facility.ghgrpid)
      end
    end
  end

  private 

  def find_or_create_summary(facility, api_summary)
    beginning_of_month = Date.current.beginning_of_month
    summary            = facility.summaries.where('created_at >= ?', beginning_of_month).first

    if summary.blank?
      summary = facility.summaries.create(
        data_year:           api_summary[:data_year],
        total_gas_emissions: api_summary[:total_facility_emissions]
      )
    else
      summary.total_gas_emissions = api_summary[:total_facility_emissions]
      summary.save
    end

    summary
  end

  def update_emissions(summary, emissions_group)
    emissions_group.each do |data_group_name, emissions|
      data_group = DataGroup.find_or_create_by(name: data_group_name)
      emissions.each do |gas, amount|
        summary.emissions.create!(data_group: data_group, gas: gas, amount: amount)
      end
    end
  end

  def update_production_information(summary, prod_info_group)
    prod_info_group.each do |data_group_name, infos|
      data_group = DataGroup.find_or_create_by(name: data_group_name)
      infos.each do |label, value|
        summary.information_details.create!(data_group: data_group, label: label, value: value)
      end
    end
  end

  def update_general_information(summary, general_info_group)
    general_info_group.each do |label, value|
      summary.information_details.create!(label: label, value: value)
    end
  end

  def attach_details_file(summary, api, ghgrpid)
    details_filepath = api.get_details_filepath
    summary.details_file.attach(io: File.open(details_filepath), filename: "ghg_facility_#{ghgrpid}.xml")
    summary.save!

    puts "Facility Summary for #{ghgrpid} was created successfully."

  rescue StandardError => e
    puts "Facility Summary for #{ghgrpid} failed to create. Errors: #{e.message}"

  ensure
    File.delete(details_filepath) if File.exist?(details_filepath)
  end
end
