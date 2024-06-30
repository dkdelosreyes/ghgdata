class Emission < ApplicationRecord
  belongs_to :summary
  belongs_to :data_group
end
