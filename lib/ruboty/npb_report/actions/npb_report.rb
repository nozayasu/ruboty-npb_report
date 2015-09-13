require "net/http"
require "uri"
require "json"

module Ruboty
  module NpbReport
    module Actions
      class NpbReport < Ruboty::Actions::Base
        NPB_API_ENDPOINT = "http://botch.herokuapp.com/v0/scores/"

        def call
          date = Date.today
          message.reply(prompt_report(date))
        end

        def prompt_report(date)
          response = call_api(date)
          body = JSON.parse(response.body)
          if response.code == "200"
            build_report(body["data"])
          else
            body["error"]["message"]
          end
        rescue => e
          "Failed by %s" % e.message
        end

        def call_api(date)
          uri = URI.parse("#{NPB_API_ENDPOINT}#{date.strftime("%Y%m%d")}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.start do |req|
            req.get(uri.request_uri)
          end
        end

        def build_report(data)
          ret = "プロ野球速報\n"
          data.each do |game|
            status = status(game["info"]["inning"])
            home_team = team(game["home"]["team"])
            home_score = game["home"]["score"]
            away_team = team(game["away"]["team"])
            away_score = game["away"]["score"]
            ret += "(H)#{home_team} #{home_score} #{status} #{away_score} #{away_team}(A)\n"
          end
          ret
        end

        def status(value)
          case value
          when "yet"
            "試合前"
          when "end"
            "結果"
          when "stop"
            "中止"
          when /([0-9]{1,2})([t,b])\z/
            "#{$1}回#{$2 == "t" ? "表" : "裏"}"
          else
            ""
          end
        end

        def team(value)
          case value
          when "G"
            "巨人"
          when "T"
            "阪神"
          when "D"
            "中日"
          when "YS"
            "ヤクルト"
          when "C"
            "広島"
          when "DB"
            "ＤｅＮＡ"
          when "H"
            "ソフトバンク"
          when "F"
            "日本ハム"
          when "BF"
            "オリックス"
          when "M"
            "ロッテ"
          when "E"
            "楽天"
          when "L"
            "西武"
          else
            ""
          end
        end
      end
    end
  end
end
