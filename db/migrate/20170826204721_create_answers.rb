class CreateAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :answers do |t|
      t.references :reply, foreign_key: true
      t.references :question, foreign_key: true
      t.references :possible_answer, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
