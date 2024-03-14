class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.string :value
      t.datetime :expires_at

      t.timestamps
    end
  end
end
