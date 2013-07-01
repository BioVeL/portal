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
# BioVeL Portal  is a prototype interface to Taverna Server which is
# provided to support easy inspection and execution of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
#!/usr/bin/env ruby
class Tavernaserv < ActiveRecord::Base

  # start checking the runs list to see if there are any workflows running
  def self.run_update(*args)
    if args.empty?
      @runs = Run.find(:all, :conditions => ["state = 'running'"])
      #If there are runing workflows then verify if they have finished
      for runner in @runs do
        update_this_run(runner)
      end
    elsif args.size == 1 and args.first.is_a? Run
      update_this_run(args.first)
    end
  end

  # verify if the indivirual workflow is still running and if not see if outputs
  # are ready to copy
  def self.update_this_run(runner)
    #update run details with the values from the server
    check_serv
    svrrun = @server.run(runner.run_identification,
                         Credential.get_taverna_credentials)
    unless svrrun.nil?
      # if the run has finished copy the outputs
      if svrrun.status.to_s == 'finished' then
        runner.expiry = svrrun.expiry
        runner.state = svrrun.status.to_s
        runner.end = svrrun.finish_time
        # if run finishes copy run output to outputs dir within run
        if runner.results.count == 0
          Rails.logger.info "Saving run:#{runner.id} results @ #{Time.now}.\n"
          #Rails.logger.info "#no results recorded for this run"
          outputs = svrrun.output_ports
          save_results(runner.id, outputs)
          runner.save
          running_time = runner.end - runner.start
          # update workflow statistics after the run has finished
          update_workflow_stats(runner.workflow_id, running_time)
          # update workflow statistics after the run has finished
          update_user_run_stats(runner.user_id, runner.workflow_id)
          # delete the run after outputs and stats have been collected
          delete_run(runner.run_identification)
        end
      end
    else
      # what if the run has finished but there are no results?
      runner.description += ' TERMINATED'
      runner.state = 'finished'
      runner.end = DateTime.now()
      runner.save
    end
  end
  def self.update_user_run_stats(user_id = 0, wf_id = 0)
    Rails.logger.info "Updating user run stats at #{Time.now}.\n"
    user_statistic = UserStatistic.where(:user_id => user_id)
    if user_statistic.nil?
      user_statistic = UserStatistic.new()
    else
      user_statistic = user_statistic[0]
    end
    user_statistic.run_count += 1
    if (user_statistic.last_run_date.nil? && user_statistic.first_run_date.nil?)
      user_statistic.last_run_date = DateTime.now()
      user_statistic.first_run_date = DateTime.now()
    else
      user_statistic.last_run_date = DateTime.now()
    end

    unless (user_statistic.last_run_date.nil? && user_statistic.first_run_date.nil?)
      months_running = ((user_statistic.last_run_date - user_statistic.first_run_date).to_i)/(60*60*24*30)
    else
      months_running = 1
    end
    if months_running < 1 then
      months_running = 1
    end
    user_statistic.latest_workflow_id = wf_id
    user_statistic.mothly_run_average = user_statistic.run_count/months_running
    user_statistic.save
  end

  def self.update_workflow_stats(wf_id = 0, running_time = 0)
    Rails.logger.info "Updating workflow stats at #{Time.now}.\n"
    wf = Workflow.find(wf_id)
    prev_run_count = wf.run_count
    prev_avg_run = wf.average_run
    wf.average_run = ((prev_run_count * prev_avg_run) + running_time ) /
                       (prev_run_count+1)
    wf.run_count = wf.run_count + 1

    if (wf.fastest_run == 0.0) || (wf.fastest_run > running_time)
      wf.fastest_run_date = DateTime.now()
      wf.fastest_run = running_time
    end
    if (wf.slowest_run < running_time)
      wf.slowest_run_date = DateTime.now()

      wf.slowest_run = running_time
    end
    wf.save
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def self.check_serv
    puts Credential.get_taverna_uri
    if (!defined?(@server) || (@server == nil)) #then
      begin
        @server = T2Server::Server.new(Credential.get_taverna_uri)
      rescue Exception => e
        @server = nil
        puts '/no_configuration'
      end
    else
      puts '/no_configuration'
    end
  end


  #this process is called to copy the results to the local result_store
  def self.save_results(runid, outputs)
    #resultset = {}
    if outputs.nil? or outputs.empty?
      Rails.logger.info "##TAVSERV SAVE_RESULTS The workflow has no output ports"
    else
      outputs.each do |name, port|
        Rails.logger.info "##TAVSERV SAVE_RESULTS #{name} (port #{port.name} depth #{port.depth})"
      begin
        if port.value.is_a?(Array)
          Rails.logger.info "##TAVSERV SAVE_RESULTS partial Results are in a list"
          sub_array = port.value
          save_nested(runid,name,sub_array,port.type[0],port.depth,index="")
        elsif port.error?
          Rails.logger.info "##TAVSERV SAVE_ERROR Results are errors"
          save_to_db(name, port.type, port.depth, runid, "#{runid}/result/#{name}.error", port.error)
        else
          Rails.logger.info "##TAVSERV SAVE_RESULTS path: #{runid}/result/#{name}  result_value: #{port.value} type: #{port.type}"
          save_to_db(name, port.type, port.depth, runid, "#{runid}/result/#{name}", port.value)
        end
      rescue
         Rails.logger.info "### ERROR CAUGHT\n\n#{$!}\n\n"
         save_to_db(name, "Error", port.depth, runid, "#{runid}/result/#{name}.error", "Result cannot be interpreted")
         Rails.logger.info "Update Error Result cannot be interpreted"
      end
      end
    end
    #resultset
  end

  def self.save_nested(runid, portname, sub_array, porttype, portdepth, index="")
    (0 .. sub_array.length - 1).each do |i|
      value = sub_array[i]
      if value.is_a?(Array) then
        save_nested(runid,portname,value,porttype, portdepth, i.to_s)
      else
        if value.nil?
          svrrun = @server.run(Run.find(runid).run_identification,
                                   Credential.get_taverna_credentials)
          value = svrrun.get_output(portname).join.to_s
        end
        puts  "#TAVSERV SAVE_NESTED path #{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i} type: #{porttype} VALUE: #{value}"
        save_to_db(portname, porttype, portdepth, runid, "#{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i}", value)
      end
    end
  end

  def self.save_to_db(name,mimetype,depth,run,filepath,value)
    result = Result.new
    result.name = name
    result.filetype = mimetype
    result.depth = depth
    result.run_id = run
    result.filepath = filepath
    result.result_file = value
    unless verify_if_saved(result) then
      Rails.logger.info "##TAVSERV SAVE_TO_DB: result #{name} for run #{run}"
      result.save
    end
  end
  def self.verify_if_saved(result)
    res = Result.where(:name => result.name,
                    :filetype => result.filetype,
                    :depth => result.depth,
                    :run_id => result.run_id,
                    :filepath => result.filepath)
    if res.count > 0 then
      Rails.logger.info "##TAVSERV VERIFY: result #{name} already in DB"
      return true;
    else
      Rails.logger.info "##TAVSERV VERIFY: result #{name} not in DB"
      return false;
    end
  end
  def  self.delete_run(run_identification)
    check_serv
    @server.delete_run(run_identification,
                         Credential.get_taverna_credentials)
  end
end
