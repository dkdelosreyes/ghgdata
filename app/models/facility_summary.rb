class FacilitySummary < ApplicationRecord
  belongs_to :facility

  has_one_attached :details_file
end
