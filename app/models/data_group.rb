class DataGroup < ApplicationRecord
  has_many :facility_emissions
  has_many :facility_informations

  validates_uniqueness_of :name
end
