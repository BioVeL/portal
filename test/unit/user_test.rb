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

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:name => nil)
      assert u.errors.include?(:name)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.include?(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => "wrong")
      assert u.errors.include?(:password)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.include?(:email)
    end
  end

  def test_should_reset_password
    users(:one).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:one), User.authenticate('Abraham', 'new password')
  end

  def test_should_not_rehash_password
    users(:one).update_attributes(:name => 'abraham2')
    assert_equal users(:one), User.authenticate('abraham2', 'password1')
  end

  def test_should_authenticate_user
    assert_equal users(:one), User.authenticate('Abraham', 'password1')
  end

protected
  def create_user(options = {})
    record = User.new({ :name => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
