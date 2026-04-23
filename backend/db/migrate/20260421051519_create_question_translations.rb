class CreateQuestionTranslations < ActiveRecord::Migration[8.0]
  def change
    create_table :question_translations do |t|
      t.references :discussion_question, null: false, foreign_key: true
      t.string :language_code, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :question_translations, [:discussion_question_id, :language_code], unique: true, name: "index_question_translations_on_question_and_lang"
  end
end
