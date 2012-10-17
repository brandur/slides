require "thread"
require "time"

module Slides
  module Log
    def log(event, attrs = {})
      unless block_given?
        str = "#{event} #{unparse(attrs)}"
        mtx.synchronize { $stdout.puts str }
      else
        start = Time.now
        log(event, attrs.merge(:at => :start))
        res = yield
        log(event, attrs.merge(:at => :finish,
          :elapsed => (Time.now - start).to_f))
        res
      end
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
