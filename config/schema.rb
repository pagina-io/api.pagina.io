DB.create_table :users do

  primary_key :id

  column :auth_token, String
  column :ip, String
  column :created_at, DateTime
  column :updated_at, DateTime
  column :github_data, :hstore

end
