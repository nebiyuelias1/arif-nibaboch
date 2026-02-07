class BuildBookFtsIndex < ActiveRecord::Migration[8.0]
  def change
    def up
      sql_query = <<-SQL
        insert into books_fts (
          books_fts
        )
       values ('rebuild')
      SQL
      execute sql_query
    end

    def down
      execute "drop table if exists books_fts"
    end
  end
end
