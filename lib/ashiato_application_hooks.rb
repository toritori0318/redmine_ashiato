require 'redmine'
require 'application_helper'
class AshiatoApplicationHooks < Redmine::Hook::ViewListener
  include ApplicationHelper

  render_on :view_layouts_base_body_bottom, :partial => 'ashiato/hook'
end

SAVE_COUNT = 10

def ashiato_register(ashiato_type, ashiato_id)
  @ashiato_all = Ashiato.all(
      :conditions => ['user_id=? AND ashiato_type=?', User.current, ashiato_type],
      :order => ['updated_on DESC'],
  )
  @ashiato_all.each do |row|
    if row.ashiato_id == ashiato_id then
      @ashiato = row
      break
    end
  end

  if !@ashiato
    Ashiato.create!(:user_id => User.current.id,
                   :ashiato_type => ashiato_type,
                   :ashiato_id => ashiato_id,
                   :updated_on => DateTime.now,
                   )
    if @ashiato_all.length >= SAVE_COUNT then
      @ashiato_all.last.delete
    end
  else
    @ashiato.updated_on = DateTime.now
    @ashiato.save
  end
  return
end
