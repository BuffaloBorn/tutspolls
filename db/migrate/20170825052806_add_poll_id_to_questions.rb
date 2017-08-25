class AddPollIdToQuestions < ActiveRecord::Migration[5.1]
  def change
    add_reference :questions, :poll, foreign_key: true
  end
end
