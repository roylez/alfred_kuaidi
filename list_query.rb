#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)

require 'json'
require 'time'
load './kuaidi'

QUERY_LIST = 'query.json'

def format_list(list)
  xml = AlfredXML.new
  list = list.sort{|a,b| a.last[:last_query] <=> b.last[:last_query]}.reverse

  xml.add_item { title '没有查到任何快递信息' } if list.empty?

  list.each do |number, record|
    xml.add_item do
      attribute     :arg,   number
      attribute     :valid, 'no'
      attribute     :autocomplete, number
      if record[:status]
        title         "#{record[:company]}    #{number}"
        icon          record[:status][:context] =~ /签收/ ?
          'pass.png' : 'package-x-generic.png'
        subtitle      format_status_record(record[:status], nil) + \
          "  ( 上次查询：#{relative_time(Time.parse record[:last_query])} )"
      else
        title         "未知快递    #{number}"
        subtitle      "  ( 上次查询：#{relative_time(Time.parse record[:last_query])} )"
        icon          "help-browser.png"
      end
    end
  end

  xml.to_s
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
