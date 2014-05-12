class City < ActiveRecord::Base
  validates :name, presence: true
end
