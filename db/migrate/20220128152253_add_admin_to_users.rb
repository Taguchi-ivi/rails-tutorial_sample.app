class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    # defalt値を付与
    add_column :users, :admin, :boolean, default:false
  end
end
