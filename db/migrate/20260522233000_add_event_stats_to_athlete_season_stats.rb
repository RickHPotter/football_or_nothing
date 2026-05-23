class AddEventStatsToAthleteSeasonStats < ActiveRecord::Migration[8.1]
  def change
    add_column :athlete_season_stats, :yellow_cards, :integer, null: false, default: 0
    add_column :athlete_season_stats, :red_cards, :integer, null: false, default: 0
    add_column :athlete_season_stats, :injuries, :integer, null: false, default: 0
  end
end
