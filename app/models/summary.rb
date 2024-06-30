class Summary < ApplicationRecord
  belongs_to :facility

  has_many :emissions, dependent: :destroy
  has_many :informations, dependent: :destroy

  has_one_attached :details_file
end
