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
    Slides.log :event, :metric => 1
    out.must_equal "event metric=1"
  end

  it "stringifies booleans" do
    Slides.log :event, :succeeded => true
    out.must_equal "event succeeded=true"
  end

  it "doesn't log nils" do
    Slides.log :event, :succeeded => nil, :city => "Berlin"
    out.must_equal "event city=Berlin"
  end

  it "doesn't wrap strings without whitespace in quotes" do
    Slides.log :event, :city => "Berlin"
    out.must_equal "event city=Berlin"
  end

  it "wraps strings with whitespace in quotes" do
    Slides.log :event, :city => "San Francisco"
    out.must_equal %{event city="San Francisco"}
  end

  it "wraps strings with whitespace and double quotes in single quotes" do
    Slides.log :query, :sql => 'SELECT * FROM "events"'
    out.must_equal %{query sql='SELECT * FROM "events"'}
  end

  it "escapes quotes in strings with both quote types" do
    Slides.log :query, :sql => %{SELECT * FROM "events" WHERE event = 'sql'}
    out.must_equal %{query sql="SELECT * FROM \\"events\\" WHERE event = 'sql'"}
  end

  it "transforms times to iso8601" do
    Slides.log :event, :at => Time.utc(2010)
    out.must_equal "event at=2010-01-01T00:00:00Z"
  end

  it "takes a block" do
    res = Slides.log(:event) { "block-return-value" }
    res.must_equal "block-return-value"
    out.must_match /event at=start/
    out.must_match /event at=finish elapsed=0.[0-9]*/
  end

  it "calls a Proc to get a value" do
    Slides.log :event, :city => Proc.new { "Berlin" }
    out.must_equal "event city=Berlin"
  end

  it "calls a lambda to get a value" do
    Slides.log :event, :city => lambda { "Berlin" }
    out.must_equal "event city=Berlin"
  end

  it "allows its stream to be set" do
    stream = StringIO.new
    Slides.stream = stream
    Slides.stream.must_equal stream
    Slides.stream = nil
  end
end
