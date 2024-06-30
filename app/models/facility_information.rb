class FacilityInformation < ApplicationRecord
  belongs_to :facility_summary
  belongs_to :data_group
end
