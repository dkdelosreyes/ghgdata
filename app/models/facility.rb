class Facility < ApplicationRecord
  has_many :summaries, dependent: :destroy

  validates_uniqueness_of :ghgrpid
end
