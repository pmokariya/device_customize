class AddFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :phone_number, :string
    add_column :users, :username, :string
    add_index :users, :username, unique: true
  end
end
