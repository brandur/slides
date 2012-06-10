module Scrolls
  module Log
    def log(action, attrs = {})
      str = "#{action} #{unparse(attrs)}"
      mtx.synchronize { $stdout.puts str }
    end

    private

    def mtx
      @mtx ||= Mutex.new
    end

    def unparse(attrs)
      attrs.map { |k, v| unparse_pair(k, v) }.join(" ")
    end

    def unparse_pair(k, v)
      # only quote strings if they include whitespace
      if v.is_a?(String) && v =~ /\s/
        %{#{k}="#{v}"}
      else
        "#{k}=#{v}"
      end
    end
  end

  extend Log
end
