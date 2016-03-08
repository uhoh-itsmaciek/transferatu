Sequel.migration do
  change do
    alter_table(:transfers) do
      add_column :from_bastion_host, :text
      add_column :from_bastion_key, :text
      add_column :to_bastion_host, :text
      add_column :to_bastion_key, :text
    end
  end
end
