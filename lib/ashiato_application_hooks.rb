require 'redmine'
require 'application_helper'
class AshiatoApplicationHooks < Redmine::Hook::ViewListener
  include ApplicationHelper

  render_on :view_layouts_base_body_bottom, :partial => 'ashiato/hook'
end

SAVE_COUNT = 30

def ashiato_register(ashiato_type, ashiato_id)
  @ashiato = Ashiato.find(
      :first,
      :conditions => ['user_id=? AND ashiato_type=? AND ashiato_id=?', User.current, ashiato_type, ashiato_id],
  )

  if !@ashiato
    Ashiato.create!(:user_id => User.current.id,
                   :ashiato_type => ashiato_type,
                   :ashiato_id => ashiato_id,
                   :updated_on => DateTime.now,
                   )
    ashiato_count = Ashiato.count(
      :conditions => ['user_id=?', User.current],
    )
    if ashiato_count >= SAVE_COUNT then
      sql = <<"SQL"
DELETE FROM ashiato
WHERE (user_id, updated_on) in (
    SELECT * FROM (
      SELECT user_id, MIN(updated_on) FROM ashiato
      WHERE user_id = ?
      GROUP BY user_id
    )iv1
  )
SQL
      ActiveRecord::Base.connection.delete(ActiveRecord::Base.send('sanitize_sql_array', [sql, User.current.id]))
    end
  else
    @ashiato.updated_on = DateTime.now
    @ashiato.save
  end
  return
end
