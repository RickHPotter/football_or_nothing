class AddUniqueCurrentContractIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :athlete_contracts, [ :athlete_id, :current ]
    remove_index :manager_contracts, [ :manager_id, :current ]
    remove_index :manager_contracts, [ :club_id, :current ]

    add_index :athlete_contracts, [ :athlete_id, :current ], unique: true, where: "current"
    add_index :manager_contracts, [ :manager_id, :current ], unique: true, where: "current"
    add_index :manager_contracts, [ :club_id, :current ], unique: true, where: "current"
  end
end
