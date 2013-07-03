# Copyright (c) 2012-2013 Cardiff University, UK.
# Copyright (c) 2012-2013 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the names of The University of Manchester nor Cardiff University nor
#   the names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Authors
#     Abraham Nieva de la Hidalga
#
# Synopsis
#
# BioVeL Taverna Lite  is a prototype interface to Taverna Server which is
# provided to support easy inspection and execution of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
gem 'ratom'
require 'atom'

class InteractionEntry < ActiveRecord::Base
  attr_accessible :author_name, :content, :href, :in_reply_to, :input_data,
   :interaction_id, :published, :response, :result_data, :result_status,
   :run_id, :taverna_interaction_id, :title, :updated

  $feed_ns = "http://ns.taverna.org.uk/2012/interaction"
  $feed_uri = "http://localhost:8080/ah/interaction/notifications?limit=500"
  def self.get_interactions
    Rails.logger.info "*****************************************************"
    Rails.logger.info "* MONITORING FEED                    ****************"
    Rails.logger.info "*****************************************************"
    counter_i = 0
    feed = Atom::Feed.load_feed(URI.parse($feed_uri))
    Rails.logger.info "Feed Entries = " + feed.entries.count.to_s
    # Go through all the entries in reverse order and add them if they are new
    feed.each_entry do |entry|
      entry_id = entry.id
      interaction_entry = InteractionEntry.find_by_interaction_id(entry_id)
      if  interaction_entry.nil?
        counter_i += 1
        interaction_entry = InteractionEntry.new(:interaction_id=>entry_id)
          # :author_name, :content, :href, :in_reply_to, :input_data,
          # :interaction_id, :published, :result_data, :result_status, :run_id,
          # :title, :updated
        entry.authors.each do |author|
          if interaction_entry.author_name.nil?
            interaction_entry.author_name = author.name.to_s
          else
            interaction_entry.author_name += " " + author.name.to_s
          end
        end
        unless entry.content.nil?
          interaction_entry.content = entry.content.to_s
        end
        #interaction_entry.content = entry.content
        entry.links.each do |link|
          if link.rel == "presentation"
            interaction_entry.href = link.to_s
	  end
        end

        interaction_entry.input_data = entry[$feed_ns, "input-data"].join.to_s
        interaction_entry.published = entry.published
        interaction_entry.result_data = entry[$feed_ns, "result-data"].join.to_s
        interaction_entry.result_status = entry[$feed_ns, "result-status"].join.to_s
        interaction_entry.run_id = entry[$feed_ns, "run-id"].join.to_s
        interaction_entry.title = entry.title
        interaction_entry.updated = entry.updated
        interaction_entry.taverna_interaction_id = entry[$feed_ns, "id"][0]
        if interaction_entry.taverna_interaction_id.nil?
          interaction_entry.response = true
        end
        unless entry[$feed_ns, "in-reply-to"].nil?
          interaction_entry.in_reply_to = entry[$feed_ns, "in-reply-to"].join.to_s
        end
        interaction_entry.save
      else
        if counter_i > 0 then
          Rails.logger.info "Saved " + counter_i.to_s + " new feed entrie(s)"
        end
        return false
      end
    end
    Rails.logger.info "Saved " + counter_i.to_s + " new feed entries"
    return true
  end
end
