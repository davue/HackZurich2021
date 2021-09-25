# Load gems
require 'active_record'
require 'csv'
require 'pry-byebug'
require 'progressbar'
require 'figaro'

# Some constants
BATCH_SIZE = 500
RECORDS_TO_FETCH = 24 * 60 * 60 * 7 # 7 days
TOTAL_SLICES = RECORDS_TO_FETCH / BATCH_SIZE

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

# Define the AR model class
class RssiRecord < ActiveRecord::Base; end

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

# Database migration class
class CreateRssiRecordTable < ActiveRecord::Migration[5.2]
  def change
    create_table :rssi_records do |t|
      t.datetime :date_time
      t.integer :area_number
      t.bigint :position
      t.bigint :position_no_leap
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

def create_tables
  CreateRssiRecordTable.migrate(:up)
end

def drop_tables
  CreateRssiRecordTable.migrate(:down)
end

def load_data
  progressbar = ProgressBar.create(
    total: TOTAL_SLICES,
    format: '%t: |%B| %p%% | %a - %e'
  )

  File.open("../data/rssi.csv") do |file|
    headers = file.first

    slice_idx = 0

    file.lazy.each_slice(BATCH_SIZE) do |lines|
      csv_rows = CSV.parse(lines.join, headers: headers)
      csv_rows.delete('ID')
      csv_rows.delete('Track')

      RssiRecord.insert_all csv_rows.map(&:to_h).each { |h| h.transform_keys!(&:underscore) }

      progressbar.increment

      slice_idx += 1

      break if TOTAL_SLICES == slice_idx
    end
  end
end
