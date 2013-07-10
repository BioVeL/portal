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
class Result < ActiveRecord::Base
  attr_accessible :depth, :filepath, :filetype, :name, :run_id, :result_file
  # every result is linked to a run, trough run_id
  belongs_to :run

  # after the result details have been written to the DB
  # write the write file to the filesystem
  after_save :store_resultfile

  # when data is assigned, store the data in a local
  # private variable for later
  def result_file=(file_data)
    unless file_data.blank?
      # store the uploaded data into a private instance variable
      @file_data = file_data
    end
  end

  RESULT_STORE = Rails.root.join('public', 'result_store')
  # define the path where workflow files will be written to:
  def result_filename
    File.join RESULT_STORE, self.filepath, "value"
  end

  #return the path that contains the result file
  def result_filepath
    return "/result_store/#{self.filepath}/value"
  end

  # check if a result file exists
  def has_resultfile?
    File.exists?  result_filename
  end
  def self.delete_files(runid)
    file_dir = File.join RESULT_STORE, "#{runid}"
    FileUtils.rm_rf(file_dir)
  end
  private
  #the store wffile method is called after the details are saved
  def store_resultfile
    # verify if there is actually a file to be saved
    if @file_data
      # create the WORKFLOW_STORE Folder if it does not exist
      FileUtils.mkdir_p File.join RESULT_STORE, self.filepath
      # create the file and write the data to the file system
      File.open(result_filename, 'wb') do |f|
        f.write(@file_data)
      end
      # ensure that the data is only save once by clearing the cache after savig
      @file_data = nil
    end
  end
end
