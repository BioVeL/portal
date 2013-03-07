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
#     Robert Haines
#     Alan Williams
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
require 't2flow/model'
require 't2flow/parser'
require 't2flow/dot'

class Workflow < ActiveRecord::Base
  attr_accessible :author, :description, :name, :title, :workflow_file, 
                  :wf_file, :my_experiment_id, :user_id, :is_shared,
                  :slowest_run, :slowest_run_date, :fastest_run, 
                  :fastest_run_date

  # a workflow can have many runs
  has_many :runs
  # after the workflow details have been written to the DB
  # write the workflow file to the filesystem
  after_save :store_wffile
  # Validate the workflow file
  validate :validate_file_is_included, :on=>:create 
  validate :validate_file_is_t2flow
  # Validate that there is a file is selected
  def validate_file_is_included
    if workflow_file.nil? && @file_data.nil?
      errors.add :workflow_file, 
                 " missing, please select a file and try again"
    end
  end
  #validate that the file is a workflow
  def validate_file_is_t2flow
    if !@file_data.nil? && !get_details_from_model
      errors.add :workflow_file, 
                 " \"" + @file_data.original_filename +
                 "\" is not a valid taverna workflow file (t2flow)"
    end
  end

  # when data is assigned via the upload, store the data in a 
  # variable for later and assing the file name to workflow_file
  def wf_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
      # set the value of workflow file to that of the original
      # workflow file name
      self.workflow_file = file_data.original_filename
    end
  end  
  
  def me_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
    end
  end   

 
  WORKFLOW_STORE = Rails.root.join('public', 'workflow_store')
  # define the path where workflow files will be written to:
  def workflow_filename
    File.join WORKFLOW_STORE, "#{id}" , "#{workflow_file}"
  end
  
  #return the path that contains the workflow file
  def workflow_filepath
    return "/workflow_store/#{id}/#{workflow_file}"
  end

  # check if a workflow file exists
  def has_workflowfile?
    File.exists?  workflow_filename
  end
  # check if workflow has parameters
  def has_parameters?
    model = T2Flow::Parser.new.parse(File.open(workflow_filename))
    model.all_sources().size > 0
  end
  # get the workflow file
  def get_file
    File.open(workflow_filename).read
  end
  # delete the workflow file
  def delete_files
    file_dir = File.join WORKFLOW_STORE, "#{id}" 
    FileUtils.rm_rf(file_dir)
  end
  # get the workflow model
  def get_model
    if FileTest.exists?(workflow_filename)
      T2Flow::Parser.new.parse(File.open(workflow_filename))
    else
      nil
    end
  end
  def get_details_from_model(authorname="Undefined")
    file_OK = false
    if @file_data
      begin
        model = T2Flow::Parser.new.parse(@file_data)
        @file_data.rewind
        if !model.nil?
          self.name = model.name
          if model.annotations.titles.join.to_s != ""
            self.title = model.annotations.titles.join.to_s
          else
            self.title = "No title provided"
          end
          if model.annotations.authors.join.to_s != ""
            self.author = model.annotations.authors.join.to_s
          else
            self.author = authorname
          end
          self.description = model.annotations.descriptions.join.to_s
        end
        file_OK = true
      rescue
        puts "Error #{$!}"
        file_OK = false
      ensure 
        @file_data.rewind
        return file_OK
      end
    end
  end 
  def connects_to_r_server?
    response = false
    for df in self.get_model.dataflows do
      for indv_proc in df.processors do
        if indv_proc.type == "rshell"
          response = true
          break
        end
      end
    end  
    return response
  end 
  def get_inputs
    sources = {}
    descriptions = {}
    # get the workflow t2flow model
    model = get_model
    # collect the sources and their descriptions
    model.sources().each{|source|
      example_values = source.example_values
      if ((!example_values.nil?) && (example_values.size == 1)) then
        sources[source.name] = example_values[0]
      else
        sources[source.name] = ""
      end
      description_values = source.descriptions
      if ((!description_values.nil?) && (description_values.size == 1)) then
        descriptions[source.name] = description_values[0]
      else
        descriptions[source.name] = ""
      end  
    }
    return [sources,descriptions]
  end
  def get_outputs
    sinks = {}
    descriptions = {}
    # get the workflow t2flow model
    model = get_model
    # collect the sinks and their descriptions
    model.sinks().each{|sink|
      example_values = sink.example_values
      if ((!example_values.nil?) && (example_values.size == 1)) then
        sinks[sink.name] = example_values[0]
      else
        sinks[sink.name] = ""
      end
      description_values = sink.descriptions
      if ((!description_values.nil?) && (description_values.size == 1)) then
        descriptions[sink.name] = description_values[0]
      else
        descriptions[sink.name] = ""
      end  
    }
    return [sinks,descriptions]
  end
  def get_processors
    # get the workflow t2flow model
    wf_model = get_model
    # collect the workflow processors and their descriptions
    return wf_model.processors()
  end
  def get_processors_in_order
    # get the workflow t2flow model
    wf_model = get_model
    ordered_processors = get_processors_order()
    ordered_processors.each do |nth_processor|
      wf_model.processors.each do |a_processor|
        if a_processor.name == nth_processor[1]
          ordered_processors[nth_processor[0]] = a_processor
        end
      end
    end    
    # collect the workflow processors and their descriptions
    return ordered_processors
  end

  def get_processors_order
    # get the workflow t2flow model
    wf_model = get_model
    # list should be as long as the number of processors
    i = wf_model.processors.count
    ordered_processors ={}
    # need a list of sources to filter them out
    wf_sources=[]
    wf_model.sources.each do |e_sou|
      wf_sources << e_sou.name
    end
    wf_model.sinks.each do |e_sink|
      wf_model.datalinks.each do |dl|
        if dl.sink == e_sink.name && 
             !ordered_processors.has_value?(dl.source.split(':')[0])
          ordered_processors[i] = dl.source.split(':')[0]
          i -= 1
        end
      end
    end

    while ordered_processors.count < wf_model.processors.count
      wf_model.datalinks.each do |lnk|
        ordered_processors.dup.each do |pr|
          unless wf_sources.include?(lnk.source.split(':')[0])
            # processors put processors in order according to data links
            unless ordered_processors.has_value?(lnk.source.split(':')[0])            
              if (lnk.sink.split(':')[0] == pr[1])
                ordered_processors[i] = lnk.source.split(':')[0]
                i -= 1 
              end
            end
          end
        end
      end
    end
    
    #return the list of processors with their orders
    return ordered_processors
  end

  private 
  #the store wffile method is called after the details are saved    
  def store_wffile
    # verify if there is actually a file to be saved
    if @file_data
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p File.join WORKFLOW_STORE, "#{id}"
    # create the file and write the data to the file system
      File.open(workflow_filename, 'wb') do |f|   
        f.write(@file_data.read)
      end
      # ensure that the data is only save once by clearing the cache after savig
      @file_data = nil
    end
  end 
end
