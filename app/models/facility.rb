class Facility < ApplicationRecord
  has_many :facility_summaries, dependent: :destroy

  validates_uniqueness_of :ghgrp_id
end
