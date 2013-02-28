require "thread"
require "time"

module Slides
  module Log
    def log(event, attrs={}, &block)
      log_array(event, attrs.map { |k, v| [k, v] }, &block)
    end

    def log_array(event, arr, &block)
      unless block
        str = "#{event} #{unparse(arr)}"
        mtx.synchronize { stream.puts str }
      else
        arr = arr.dup
        start = Time.now
        arr << [:at, :start]
        log(event, arr)
        res = yield
        arr.pop
        arr << [:at, :finish] << [:elapsed, (Time.now - start).to_f]
        log(event, arr)
        res
      end
    end

    def stream
      @stream || $stdout
    end

    def stream=(val)
      @stream = val
    end

    private

    def mtx
      @mtx ||= Mutex.new
    end

    def quote_string(k, v)
      # try to find a quote style that fits
      if !v.include?('"')
        %{#{k}="#{v}"}
      elsif !v.include?("'")
        %{#{k}='#{v}'}
      else
        %{#{k}="#{v.gsub(/"/, '\\"')}"}
      end
    end

    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.compact.join(" ")
    end

    def unparse_pair(k, v)
      v = v.call if v.is_a?(Proc)
      # only quote strings if they include whitespace
      if v == nil
        nil
      elsif v.is_a?(Float)
        "#{k}=#{format("%.3f", v)}"
      elsif v.is_a?(String) && v =~ /\s/
        quote_string(k, v)
      elsif v.is_a?(Time)
        "#{k}=#{v.iso8601}"
      else
        "#{k}=#{v}"
      end
    end
  end

  extend Log
end
