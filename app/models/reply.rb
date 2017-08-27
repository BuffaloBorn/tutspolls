class Reply < ApplicationRecord
  belongs_to :poll
  has_many :answers

  accepts_nested_attributes_for :answers
end
