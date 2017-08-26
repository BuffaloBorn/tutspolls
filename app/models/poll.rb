class Poll < ApplicationRecord
  validates_presence_of :title

  # Relationships
  has_many :questions

end
