require "stringio"
require "test_helper"

describe Slides::Log do
  before do
    $stdout = StringIO.new
  end

  def out
    $stdout.string.strip
  end

  it "sends logs to $stdout" do
    Slides.log :event, metric: 1
    out.must_equal "event metric=1"
  end

  it "stringifies booleans" do
    Slides.log :event, succeeded: true
    out.must_equal "event succeeded=true"
  end

  it "does wrap strings with whitespace in quotes" do
    Slides.log :event, city: "Berlin"
    out.must_equal "event city=Berlin"
  end

  it "doesn't wrap strings without whitespace in quotes" do
    Slides.log :event, city: "San Francisco"
    out.must_equal %{event city="San Francisco"}
  end

  it "takes a block" do
    res = Slides.log(:event) { "block-return-value" }
    res.must_equal "block-return-value"
    out.must_match /event at=start/
    out.must_match /event at=finish elapsed=[0-9]*ms/
  end

  it "calls a Proc to get a value" do
    Slides.log :event, city: Proc.new { "Berlin" }
    out.must_equal "event city=Berlin"
  end

  it "calls a lambda to get a value" do
    Slides.log :event, city: -> { "Berlin" }
    out.must_equal "event city=Berlin"
  end
end