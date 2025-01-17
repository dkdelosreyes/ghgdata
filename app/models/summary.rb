class Summary < ApplicationRecord
  belongs_to :facility

  has_many :emissions, dependent: :destroy
  has_many :information_details, dependent: :destroy

  has_one_attached :details_file

  class << self
    def latest
      order(created_at: :desc).first
    end
  end
end
