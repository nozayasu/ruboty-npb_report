require "ruboty/npb_report/actions/npb_report"

module Ruboty
  module Handlers
    class NpbReport < Base
      on /npb report\z/, name: "npb_report", description: "show prompt report of npb"

      def npb_report(message)
        Ruboty::NpbReport::Actions::NpbReport.new(message).call
      end
    end
  end
end
