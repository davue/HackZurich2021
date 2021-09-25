# Load gems
require 'active_record'
require 'csv'
require 'pry-byebug'
require 'progressbar'
require 'figaro'

# Some constants
BATCH_SIZE = 500

# Load secrets from figaro
Figaro.application = Figaro::Application.new(path: 'config/application.yml')
Figaro.load

# Connect to the azure DB
ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  host:     'siemens-challenge.postgres.database.azure.com',
  username: 'siemens_hack@siemens-challenge',
  password: Figaro.env.db_password,
  database: Figaro.env.db_name
)

# Check if we're connected, abort if not
ActiveRecord::Base.connection
unless ActiveRecord::Base.connected? 
  fail 'Could not connect to DB'
end

# Define the AR model classes
class RssiRecord < ActiveRecord::Base; end

class Disruption < ActiveRecord::Base; end

# Helper method to turn a camel-cased string to a snake-cased string
class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

# Database migration classes
class CreateRssiRecordTable < ActiveRecord::Migration[6.1]
  def change
    create_table :rssi_records do |t|
      t.datetime :date_time, index: true
      t.integer :area_number
      t.bigint :position, index:true
      t.bigint :position_no_leap, index: true
      t.decimal :longitude, precision: 18, scale: 14
      t.decimal :latitude, precision: 18, scale: 14
      t.bigint :a1_total_tel
      t.bigint :a1_valid_tel
      t.bigint :a2_total_tel
      t.bigint :a2_valid_tel
      t.decimal :a2_rssi, precision: 4, scale: 3
    end
  end
end

class CreateDisruptionsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :disruptions do |t|
      t.datetime :date_time, index: true
      t.string :disruption_code
      t.string :description
    end
  end
end

def create_tables
  CreateRssiRecordTable.migrate(:up)
  CreateDisruptionsTable.migrate(:up)
end

def drop_tables
  CreateRssiRecordTable.migrate(:down)
  CreateDisruptionsTable.migrate(:down)
end


def load_rssi_data(month)
  month_counts = {
    feb: 2_237_875,
    mar: 2_247_918,
    apr: 1_420_853
  }

  rssi_records_to_fetch = month_counts[month]
  total_slices = rssi_records_to_fetch / BATCH_SIZE

  progressbar = ProgressBar.create(
    total: total_slices,
    format: '%t: |%B| %p%% | %a - %e'
  )

  # Put RSSI data in table
  File.open("../data/rssi_#{month}.csv") do |file|
    headers = file.first

    file.lazy.each_slice(BATCH_SIZE) do |lines|
      csv_rows = CSV.parse(lines.join, headers: headers)
      csv_rows.delete('ID')
      csv_rows.delete('Track')

      RssiRecord.insert_all csv_rows.map(&:to_h).each { |h| h.transform_keys!(&:underscore) }

      progressbar.increment
    end
  end
end

def load_disruption_data
  # Put disruption data into table
  File.open("../data/disruptions.csv") do |file|
    headers = file.first

    file.lazy.each_slice(BATCH_SIZE) do |lines|
      csv_rows = CSV.parse(lines.join, headers: headers)
      csv_rows.delete('ID')

      Disruption.insert_all csv_rows.map(&:to_h).each { |h| h.transform_keys!(&:underscore) }
    end
  end
end

case ARGV.first
when 'up'
  create_tables
when 'down'
  drop_tables
when 'load_rssi_feb'
  load_rssi_data(:feb)
when 'load_rssi_mar'
  load_rssi_data(:mar)
when 'load_rssi_apr'
  load_rssi_data(:apr)
when 'load_disruptions'
  load_disruption_data
else
  puts 'Nothing to do :)'
end
