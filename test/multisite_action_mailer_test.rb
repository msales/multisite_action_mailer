require 'test/unit'
require File.join(File.dirname(__FILE__),'test_helper')
require File.join(File.dirname(__FILE__), "..", "lib", "multisite_action_mailer")

$last_used_template_root = nil
class TestMailer < ActionMailer::Base  
  def test_mail
    $last_used_template_root = template_root
  end
  
  def test_mail_only_in_other_view_path
    $last_used_template_root = template_root
  end

  def test_mail_with_missing_template
    $last_used_template_root = template_root
  end
end

$view_path = File.join(File.dirname(__FILE__), 'views')
$other_view_path = File.join(File.dirname(__FILE__), 'other_views')

class MultiSiteActionMailer < Test::Unit::TestCase

  def test_that_aliasing_works
    assert(ActionMailer::Base.methods.include?("method_missing_with_multisite"), ActionMailer::Base.methods.inspect)
    assert(ActionMailer::Base.methods.include?("method_missing_without_multisite"), ActionMailer::Base.methods.inspect)
  end
  
  def test_with_only_one_root
    ActionController::Base.view_paths = [$view_path]
    TestMailer.create_test_mail
    assert_equal($last_used_template_root, $view_path)
  end

  def test_with_other_root_first
    ActionController::Base.view_paths = [$other_view_path, $view_path]
    TestMailer.create_test_mail
    assert_equal($last_used_template_root, $other_view_path)
  end

  def test_use_template_in_second_path
    ActionController::Base.view_paths = [$view_path, $other_view_path]
    TestMailer.create_test_mail_only_in_other_view_path
    assert_equal($last_used_template_root, $other_view_path)
  end
  
  def test_raise_error_with_missing_template
    ActionController::Base.view_paths = [$view_path, $other_view_path]
    assert_raise(ActionView::MissingTemplate) {
      TestMailer.create_test_mail_with_missing_template      
    }
  end
end
