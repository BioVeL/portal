#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
require File.join(root, "config", "environment")
Rails.logger.info "Updater daemon started at #{Time.now}.\n"

$running = true
Signal.trap("TERM") do 
  $running = false
  Rails.logger.info "Updater daemon stopped at #{Time.now}.\n"
end

while($running) do
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  Tavernaserv.run_update  
  
  sleep 10
end
