module ApplicationHelper
  def button_select(model_name, target_property, button_source)
    html=''
    list=button_source.sort
    if list.count > 0
      html << label(model_name, target_property) << '<br />'
    end
    if list.count < 4
      list.each{|x|
        html << radio_button(model_name, target_property, x[1])
        html << h(x[0])
        html << '<br />'
      }
    else
      html << select(model_name, target_property,list)
    end
    
    return html.html_safe
  end
  def current_announcements
    @current_announcements ||= Announcement.current_announcements(session[:announcement_hide_time])
  end
end
