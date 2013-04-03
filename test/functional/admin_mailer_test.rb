require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  test "server_unresponsive" do
    mail = AdminMailer.server_unresponsive
    assert_equal "Server unresponsive", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
