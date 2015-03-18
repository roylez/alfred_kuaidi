#!/usr/bin/env ruby
# encoding: utf-8
#Description:

require_relative 'alfred'

load 'kuaidi'

def format_alfred_detail(detail)

  al = AlfredXML.new
  unless detail[:message] == 'ok'
    al.add_item do
      title detail[:message]
    end
    return al.to_s
  end

  al.add_item do
    attribute :arg, detail[:data].collect{|r| format_status_record(r,nil)}.join(";")
    title     decode_company( detail[:com]) + '    ' + detail[:nu]
    icon      'icon.png'
    subtitle  '按 Enter 将快递状态复制到剪切板'
  end

  total = detail[:data].size
  detail[:data].each.with_index do |record, ind|
    al.add_item do
      title     ("[%02d]" %  (total - ind)  + ' ' + record[:context].gsub(/\s+/, ' '))
      subtitle  record[:time]
      icon      record[:context] =~ /签收/ ? 'success.png' : ( ind.zero? ? 'truck.png' : 'up.png' )
      attribute :valid, 'no'
    end
  end

  al.to_s
end

package = ARGV.first

detail = kuaidi_status(package, saved_pacakge_detail(package, :code))

detail ||= {:status => 'error', :message => "没找到有关快递单 #{package} 的信息"}

puts format_alfred_detail(detail)

record_query(SAVE_FILE, package, detail)
