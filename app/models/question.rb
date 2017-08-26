class Question < ApplicationRecord
  belongs_to :poll
  has_many :possible_answers
end
