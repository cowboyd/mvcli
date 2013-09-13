require "spec_helper"

describe "using the `mvcli` tool to generate a new application" do
  Given(:process) { run "mvcli create application matterhorn" }
  When(:status) { process.stop nil }
  Then { the_matterhorn_directory_is_created_in_the_current_directory }
  And { all_the_basic_support_files_are_created_in_the_matterhorn_directory }
  And { status == 0 }

  describe "generating a new controller" do
    Given { cd "matterhorn" }
    Given(:process) { mvcli "generate controller" }
    When(:status) { process.stop nil }
    Then { process.should_not have_failed }
  end
  describe "generating a new provider"

  describe "installing a plugin" do

  end

  def the_matterhorn_directory_is_created_in_the_current_directory
    true
  end

  def all_the_basic_support_files_are_created_in_the_matterhorn_directory
    true
  end
end
