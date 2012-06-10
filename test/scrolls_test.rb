require "stringio"
require "test_helper"

describe Scrolls::Log do
  before do
    $stdout = StringIO.new
  end

  def out
    $stdout.string.strip
  end

  it "sends logs to $stdout" do
    Scrolls.log :event, metric: 1
    out.must_equal "event metric=1"
  end

  it "stringifies booleans" do
    Scrolls.log :event, succeeded: true
    out.must_equal "event succeeded=true"
  end

  it "does wrap strings with whitespace in quotes" do
    Scrolls.log :event, city: "Berlin"
    out.must_equal "event city=Berlin"
  end

  it "doesn't wrap strings without whitespace in quotes" do
    Scrolls.log :event, city: "San Francisco"
    out.must_equal %{event city="San Francisco"}
  end
end
