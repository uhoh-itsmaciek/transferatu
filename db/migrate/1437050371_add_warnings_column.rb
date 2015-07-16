Sequel.migration do
  change do
    alter_table(:transfers) do
      add_column :warnings, :integer
    end
  end
end
