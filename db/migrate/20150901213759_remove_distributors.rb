class RemoveDistributors < ActiveRecord::Migration[4.2]
  class Katello::Distributor < ApplicationRecord
    self.table_name = 'katello_distributors'
  end

  def up
    drop_table "katello_distributors"
  end

  def down
    create_table "katello_distributors", :force => true do |t|
      t.string   "uuid", :limit => 255
      t.string   "name", :limit => 255
      t.text     "description"
      t.string   "location", :limit => 255
      t.integer  "environment_id"
      t.datetime "created_at",      :null => false
      t.datetime "updated_at",      :null => false
      t.integer  "content_view_id"
    end

    add_index "katello_distributors", ["content_view_id"], :name => "index_distributors_on_content_view_id"
    add_index "katello_distributors", ["environment_id"], :name => "index_distributors_on_environment_id"
  end
end
