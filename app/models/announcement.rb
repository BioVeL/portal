class Announcement < ActiveRecord::Base
  attr_accessible :ends_at, :message, :starts_at
  
  def self.current_announcements(hide_time)
    #with_scope :find => { 
    #    :conditions => "starts_at <= NOW() AND ends_at >= NOW()" 
    with_scope :find => { 
        :conditions => "starts_at <= datetime('now') AND ends_at >= datetime('now')" 
      } do
      if hide_time.nil?
        find(:all)
      else
        find(:all, :conditions => ["updated_at > ? OR starts_at > ?", hide_time, hide_time])
      end
    end
  end
end
