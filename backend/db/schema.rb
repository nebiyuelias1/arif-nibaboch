# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_06_123441) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "book_tags", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "tag_id"], name: "index_book_tags_on_book_id_and_tag_id", unique: true
    t.index ["book_id"], name: "index_book_tags_on_book_id"
    t.index ["tag_id"], name: "index_book_tags_on_tag_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author"
    t.text "description"
    t.date "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "language", default: "am"
    t.string "cover_image"
    t.string "publisher"
    t.string "isbn"
    t.float "average_rating", default: 0.0, null: false
    t.integer "reviews_count", default: 0, null: false
    t.string "telegram_post_id"
    t.string "source"
    t.string "source_url"
    t.string "title_en"
    t.string "title_romanized"
    t.string "author_romanized"
    t.integer "page_count"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_ratings_on_book_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "telegram_id"
    t.string "name"
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "book_tags", "books"
  add_foreign_key "book_tags", "tags"
  add_foreign_key "ratings", "books"
  add_foreign_key "ratings", "users"
end
