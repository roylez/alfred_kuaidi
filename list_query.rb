#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)

require 'json'
require 'time'
load './kuaidi'

QUERY_LIST = 'query.json'

def format_list(list)
  require 'rexml/document'
  include REXML
  root = Element.new('items')

  list = list.sort{|a,b| a.last[:last_query] <=> b.last[:last_query]}.reverse
  if list.empty?
    item = Element.new('item')
    title = Element.new('title')
    title.text = "没有查到任何快递信息"
    item << title
    root << item
  end

  list.each do |number, record|
    item = Element.new('item')
    item.add_attribute('arg', number)
    item.add_attribute('valid', 'no')
    item.add_attribute('autocomplete', "#{number}:#{record[:code]}")
    title = Element.new('title')
    title.text = "#{record[:company]}    #{number}"
    subtitle = Element.new('subtitle')
    subtitle.text = format_status_record(record[:status], nil) + \
      "  ( 上次查询：#{relative_time(Time.parse record[:last_query])} )"
    icon = Element.new('icon')
    icon.text = 'package-x-generic.png'
    [title, icon, subtitle].each {|i| item << i }
    root << item
  end
  root.to_s
end

def relative_time(start_time)
  start_time = start_time.to_i
  diff_seconds = Time.now.to_i - start_time
  case diff_seconds
    when 0 .. 10
      "数秒钟前"
    when 11 .. 59
      "#{diff_seconds.to_i}秒前"
    when 60 .. (3600-1)
      "#{diff_seconds/60}分钟前"
    when 3600 .. (3600*24-1)
      "#{diff_seconds/3600}小时前"
    when (3600*24) .. (3600*24*30)
      "#{diff_seconds/(3600*24)}天前"
    else
      Time.at(start_time).strftime("%Y年%m月%d日")
  end
end

results = {}
if File.file? QUERY_LIST
  results = JSON.parse(open(QUERY_LIST).read.force_encoding('UTF-8'), :symbolize_names => true)
end
puts format_list(results)
