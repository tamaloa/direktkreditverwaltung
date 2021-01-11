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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210111214207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_entries", force: :cascade do |t|
    t.date     "date"
    t.decimal  "amount",                 precision: 14, scale: 2
    t.integer  "contract_id"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.boolean  "annually_closing_entry",                          default: false
    t.boolean  "interest_entry",                                  default: false
  end

  add_index "accounting_entries", ["contract_id"], name: "index_accounting_entries_on_contract_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "gmbh_name",            limit: 255
    t.string   "verein_name",          limit: 255
    t.string   "street",               limit: 255
    t.string   "zip_code",             limit: 255
    t.string   "city",                 limit: 255
    t.string   "email",                limit: 255
    t.string   "web",                  limit: 255
    t.string   "bank_name",            limit: 255
    t.string   "bank_account_info",    limit: 255
    t.string   "gmbh_executive_board", limit: 255
    t.string   "gmbh_register_number", limit: 255
    t.string   "gmbh_tax_number",      limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "prename",        limit: 255
    t.string   "address",        limit: 255
    t.string   "account_number", limit: 255
    t.string   "bank_number",    limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "email",          limit: 255
    t.string   "phone",          limit: 255
    t.string   "remark",         limit: 255
    t.string   "bank_name",      limit: 255
  end

  create_table "contract_versions", force: :cascade do |t|
    t.date     "start"
    t.integer  "duration_months"
    t.integer  "duration_years"
    t.decimal  "interest_rate",   precision: 5, scale: 4
    t.integer  "version"
    t.integer  "contract_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "notice_period"
    t.date     "end_date"
  end

  add_index "contract_versions", ["contract_id"], name: "index_contract_versions_on_contract_id", using: :btree

  create_table "contracts", force: :cascade do |t|
    t.string   "number"
    t.integer  "contact_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "comment",                          limit: 255
    t.string   "category",                         limit: 255
    t.boolean  "add_interest_to_deposit_annually",             default: true
    t.date     "terminated_at"
  end

  add_index "contracts", ["contact_id"], name: "index_contracts_on_contact_id", using: :btree
  add_index "contracts", ["terminated_at"], name: "index_contracts_on_terminated_at", using: :btree

  create_table "contracts_emails", id: false, force: :cascade do |t|
    t.integer "contract_id"
    t.integer "email_id"
  end

  create_table "emails", force: :cascade do |t|
    t.integer  "mail_template_id"
    t.string   "status",           limit: 255
    t.integer  "year"
    t.integer  "contact_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "mail_templates", force: :cascade do |t|
    t.string   "subject",                 limit: 255
    t.text     "content"
    t.text     "footer"
    t.integer  "year"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "newsletter_file_name",    limit: 255
    t.string   "newsletter_content_type", limit: 255
    t.integer  "newsletter_file_size"
    t.datetime "newsletter_updated_at"
    t.datetime "test_mail_sent_at"
    t.string   "filename"
    t.string   "content_type"
    t.binary   "file_content"
    t.datetime "all_mail_sent_at"
  end

end
