class InformationDetail < ApplicationRecord
  belongs_to :summary
  belongs_to :data_group, optional: true
end
