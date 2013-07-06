class AshiatoController < ApplicationController
  unloadable

  def index

    issues = params[:show_issues]
    messages = params[:show_messages]
    wiki_pages = params[:show_wiki_pages]
    if !issues && !wiki_pages && !messages then
      issues     = 1
      messages   = 1
      wiki_pages = 1
    end

    @event_types_inc = []
    @event_types_inc.push('issues') if issues
    @event_types_inc.push('messages') if messages
    @event_types_inc.push('wiki_pages') if wiki_pages

    @author = User.current
    @event_types = ['issues', 'wiki_pages', 'messages']
    @ashiato = get_merge_ashiato(issues, messages, wiki_pages)
  end

  def get_merge_ashiato(issues, messages, wiki_pages)
    binds = []

    sqls = []
    if issues then
      sqls.push(<<"SQL")
 SELECT issues.id as id, issues.project_id as project_id, projects.name as project_name, issues.subject as title, ashiato.ashiato_type as ashiato_type, ashiato.updated_on as updated_on, '' as board_id FROM ashiato
   LEFT JOIN issues
    ON ashiato.ashiato_id = issues.id
   LEFT JOIN projects
    ON projects.id = issues.project_id
  WHERE ashiato.user_id=? and ashiato_type='issue'
SQL
    end

    if messages then
      sqls.push(<<"SQL")
 SELECT messages.id as id, boards.project_id as project_id, projects.name as project_name, messages.subject as title, ashiato.ashiato_type as ashiato_type, ashiato.updated_on as updated_on, boards.id as board_id  FROM ashiato
   LEFT JOIN messages
    ON ashiato.ashiato_id = messages.id
   LEFT JOIN boards
    ON messages.board_id = boards.id
   LEFT JOIN projects
    ON projects.id = boards.project_id
  WHERE ashiato.user_id=? and ashiato_type='message'
SQL
    end

    if wiki_pages then
      sqls.push(<<"SQL")
 SELECT wiki_pages.id as id, wikis.project_id as project_id, projects.name as project_name, wiki_pages.title as title, ashiato.ashiato_type as ashiato_type, ashiato.updated_on as updated_on, '' as board_id FROM ashiato
   LEFT JOIN wiki_pages
    ON ashiato.ashiato_id = wiki_pages.id
   LEFT JOIN wikis
    ON wiki_pages.wiki_id = wikis.id
   LEFT JOIN projects
    ON projects.id = wikis.project_id
  WHERE ashiato.user_id=? and ashiato_type='wiki-page'
SQL
    end

    sql = sprintf("SELECT * FROM (%s) iv ORDER BY updated_on DESC", sqls.join("UNION ALL"))
    binds = []
    sqls.length.times { binds.push(User.current.id) }
    ActiveRecord::Base.connection.select_all(ActiveRecord::Base.send('sanitize_sql_array', [sql, *binds]))
  end

end
