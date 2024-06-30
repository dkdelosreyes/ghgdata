json.type 'FeatureCollection'
json.features do
  json.array! @facilities do |facility|
    json.type 'Feature'
    json.geometry do
      json.type 'Point'
      json.coordinates [facility.longitude, facility.latitude]
    end
    json.properties do
      json.ghgrpid facility.ghgrpid
      json.name    facility.name

      json.summary do 
        summary = facility.summaries.latest

        if summary.present?
          json.total_gas_emissions summary.total_gas_emissions

          emissions_grouped = summary.emissions.each_with_object({}) do |emission, hash|
            group_name = emission.data_group.name
            hash[group_name] ||= []
            hash[group_name] << { gas: emission.gas, amount: emission.amount }
          end

          # Render the organized emissions
          emissions_grouped.each do |group_name, emissions|
            json.set! group_name do
              json.array! emissions do |emission|
                json.gas emission[:gas]
                json.amount emission[:amount]
              end
            end
          end

          information_grouped = summary.information_details.each_with_object({}) do |info, hash|

            if info.data_group.present?
              group_name = info.data_group&.name
              hash[group_name] ||= []
              hash[group_name] << { label: info.label, value: info.value }
            else
              hash[info.label] = info.value
            end
          end

          # Render the organized information details
          information_grouped.each do |group_name, infos|

            if infos.is_a?(Array)
              json.set! group_name do
                json.array! infos do |detail|
                  json.label detail[:label]
                  json.value detail[:value]
                end
              end
            else
              json.set! group_name, infos
            end
          end
        end
      end
    end
  end
end