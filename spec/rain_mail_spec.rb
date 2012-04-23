#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rain_mail'

describe RainMail do
  before do
    @rain_mail = RainMail.new
  end
  subject { @rain_mail }

  describe '#rainy?' do
    context "雨予報のとき" do
      it 'はtrueであること' do
        should be_rainy('雨')
      end
    end
    context "晴れ予報のとき" do
      it 'はfalseであること' do
        should_not be_rainy('晴れ')
      end
    end
  end

  describe '#forecast_weather' do
    its(:forecast_weather) { should_not be_nil }
  end
end
