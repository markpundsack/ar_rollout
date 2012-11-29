require 'rake'

describe "rollout:list" do
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "ar_rollout_tasks", [File.expand_path("../../../../lib/tasks", __FILE__)]
    Rake::Task.define_task(:environment)
  end

  it "lists the features" do
    ArRollout.stub(:features).and_return(["feature one", "feature two"])
    STDOUT.should_receive(:puts).with(["feature one", "feature two"])
    @rake["rollout:list"].invoke
  end
end
