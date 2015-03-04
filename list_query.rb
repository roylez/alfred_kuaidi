#!/usr/bin/env ruby
# coding: utf-8
#Author: Roy L Zuo (roylzuo at gmail dot com)

require 'json'
require 'time'
require_relative 'alfred'
load './kuaidi'

QUERY_LIST = 'query.json'

def format_list(list)
  list = list.sort{|a,b| a.last[:last_query] <=> b.last[:last_query]}.reverse
  res = []

  res << [ {}, :title => '没有查到任何快递信息'] if list.empty?

  list.each do |number, record|
    res << [
      {
        :arg          => number,
        :valid        => 'no',
        :autocomplete => number,
      },
      record[:status] ?
        {
        :title    => "#{record[:company]}    #{number}",
        :icon     => record[:status][:context] =~ /签收/ ? 'success.png' : 'truck.png',
        :subtitle => format_status_record(record[:status], nil) + "  ( 上次查询：#{relative_time(Time.parse record[:last_query])} )",
        }
        :
        {
          :title    => "未知快递    #{number}",
          :subtitle => "  ( 上次查询：#{relative_time(Time.parse record[:last_query])} )",
          :icon     => "question.png",
        }
    ]
  end
  res
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

def possible_clipboard_tracking_number
  clipstring = `pbpaste`.strip
  clipstring =~ /^\w+$/ ? clipstring : nil
end

results = {}
if File.file? QUERY_LIST
  results = JSON.parse(open(QUERY_LIST).read.force_encoding('UTF-8'), :symbolize_names => true)
end
list = format_list(results)

if tracking_number = possible_clipboard_tracking_number
  list.unshift(
    [
      {:valid => 'no', :autocomplete => tracking_number},
      {:title    => "[剪切板] 查询: #{tracking_number}",
       :subtitle => '按 Enter 把剪切板里的内容作为快递单号查询',
       :icon     => 'paste.png'
      }
    ]
  )
end

puts AlfredXML.from_list list
