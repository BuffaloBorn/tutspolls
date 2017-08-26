class CreatePossibleAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :possible_answers do |t|
      t.references :question, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
