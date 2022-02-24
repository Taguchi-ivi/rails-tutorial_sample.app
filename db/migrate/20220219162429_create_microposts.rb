class CreateMicroposts < ActiveRecord::Migration[6.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # user_id,created_atをindexを付与することで、user_idに紐づけられたすべての投稿を作成した逆順で表示しやすくなる
    # 一つの配列に二つの値を格納している。両方のキーを同時に扱う複合キーインデックス（Multiple Key Index）を作成
    add_index :microposts, [:user_id, :created_at]
  end
end
