class AddDataImportFoundation < ActiveRecord::Migration[8.1]
  def change
    create_table :data_import_runs do |t|
      t.string :source, null: false
      t.integer :status, null: false, default: 0
      t.integer :records_processed, null: false, default: 0
      t.text :notes
      t.datetime :started_at, null: false
      t.datetime :finished_at

      t.timestamps
    end

    add_external_identity :countries
    add_external_identity :clubs
    add_external_identity :athletes
    add_external_identity :athlete_contracts
  end

  private

  def add_external_identity(table)
    add_column table, :external_source, :string
    add_column table, :external_id, :string
    add_index table, [ :external_source, :external_id ], unique: true, where: "external_source IS NOT NULL AND external_id IS NOT NULL"
  end
end
