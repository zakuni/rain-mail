#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'yaml'
require 'open-uri'
require 'rexml/document'
require 'kconv'
require 'net/smtp'

class RainMail
	def rainy?(weather)
		return true if weather.include? "雨"
	end

	# 参考: http://d.hatena.ne.jp/yonetin/20120118/1326896786
	# http://d.hatena.ne.jp/gan2/20070604/1180974366
	def forecast_weather
		uri = "http://weather.livedoor.com/forecast/webservice/rest/v1?city=70&day=tomorrow"
		doc = nil
		begin
			open(uri) do |uri|
				doc = REXML::Document.new(uri)
			end
			doc.elements["lwws"].elements["telop"].text
		rescue SocketError
			puts"SocketError:#{uri}"
		rescue OpenURI::HTTPError
			puts"HTTPError:#{uri}"
		end
	end

	def send_mail(subject, body)
		conf ||= YAML.load_file(File.dirname(__FILE__) + '/config.yaml')
		smtp_server = conf['smtp_server']
		smtp_port   = conf['smtp_port']
		from_addr   = conf['from_addr']
		to_addrs    = conf['to_addrs']
		user        = conf['user']
		pass        = conf['pass']

		smtp = Net::SMTP.new(smtp_server, smtp_port)
		smtp.enable_starttls
		smtp.start('localhost.localdomain', user, pass, :plain) do |connection|
			connection.send_mail(<<EOS , from_addr, *to_addrs)
Date: #{Time::now.strftime("%a, %d %b %Y %X")}
From: #{from_addr}
To: #{to_addrs.join(",")}
Subject: #{subject.encode("Shift_JIS")}
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS

#{body.encode("Shift_JIS")}
EOS
		end
	end
end

rain_mail = RainMail.new
weather = rain_mail.forecast_weather
if rain_mail.rainy? weather then
	subject = "今日#{weather}らしいから"
	body    = "傘持って行くとよいよ。どちらでもよいよ。\nhttp://weather.livedoor.com/area/14/70.html"
	rain_mail.send_mail(subject, body)
end
