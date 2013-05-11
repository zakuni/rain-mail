#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'yaml'
require 'kconv'
require 'net/smtp'
require 'weather-report'

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

weather = WeatherReport.get("横浜")
tomorrow = weather.tomorrow

subject_body = { "明日#{tomorrow.telop}らしいから" => "洗濯物干さないほうがよいよ。どちらでもよいよ。\n#{weather.link}",
                 "明日いつから#{tomorrow.telop}なの?" => "明日の天気はもう、生まれたて。 \n#{weather.link}" }

if tomorrow.umbrella? then
  subject = subject_body.keys[rand(subject_body.length)]
  body = subject_body[subject]
  send_mail(subject, body)
end
