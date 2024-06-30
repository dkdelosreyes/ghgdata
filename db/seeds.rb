require 'roo'

# NOTE: Initialize the Facilities table using the data from an excel
file_path = Rails.root.join('db', 'seeds', 'ghg-data.xlsx')
xlsx      = Roo::Spreadsheet.open(file_path.to_s)

sheet = xlsx.sheet(0) # Get first sheet

success = 0
failed = 0

sheet.each(headers: true).with_index do |row, index|
  next if index.zero? # Skip header
  
  attributes = {
    name:       row['FACILITY NAME'],
    ghgrpid:    row['GHGRP ID'],
    latitude:   row['LATITUDE'],
    longitude:  row['LONGITUDE']
  }

  facility = Facility.new(attributes)

  if !facility.save
    puts "Facility #{facility.name} failed to create. Errors: #{facility.errors.full_messages.join(', ')}"
    failed = failed + 1
  else
    puts "Facility #{facility.name} was created successfully."
    success = success + 1
  end
end

puts "Seeding completed successfully. Success count: #{success}, Failed count: #{failed}"