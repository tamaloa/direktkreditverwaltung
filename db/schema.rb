# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150201170400) do

  create_table "accounting_entries", :force => true do |t|
    t.date     "date"
    t.decimal  "amount",                 :precision => 14, :scale => 2
    t.integer  "contract_id"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.boolean  "annually_closing_entry",                                :default => false
    t.boolean  "interest_entry",                                        :default => false
  end

  add_index "accounting_entries", ["contract_id"], :name => "index_accounting_entries_on_contract_id"

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "gmbh_name"
    t.string   "verein_name"
    t.string   "street"
    t.string   "zip_code"
    t.string   "city"
    t.string   "email"
    t.string   "web"
    t.string   "bank_name"
    t.string   "bank_account_info"
    t.string   "gmbh_executive_board"
    t.string   "gmbh_register_number"
    t.string   "gmbh_tax_number"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "prename"
    t.string   "address"
    t.string   "account_number"
    t.string   "bank_number"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "email"
    t.string   "phone"
    t.string   "remark"
    t.string   "bank_name"
  end

  create_table "contract_versions", :force => true do |t|
    t.date     "start"
    t.integer  "duration_months"
    t.integer  "duration_years"
    t.decimal  "interest_rate",   :precision => 5, :scale => 4
    t.integer  "version"
    t.integer  "contract_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "contract_versions", ["contract_id"], :name => "index_contract_versions_on_contract_id"

  create_table "contracts", :force => true do |t|
    t.integer  "number"
    t.integer  "contact_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "comment"
    t.string   "category"
    t.boolean  "add_interest_to_deposit_annually", :default => true
    t.date     "terminated_at"
  end

  add_index "contracts", ["contact_id"], :name => "index_contracts_on_contact_id"
  add_index "contracts", ["terminated_at"], :name => "index_contracts_on_terminated_at"

end
