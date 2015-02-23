#!/usr/bin/env ruby
# coding: utf-8
#Description:
#
# Usage:
#   alfred = AlfredXML.new
#   alfred.add_item do
#     title 'some title'    # required
#     subtitle 'subtitle'
#     icon  'some icon'
#     attribute
#   end
#

require 'rexml/document'
include REXML

class AlfredXML < Element
  def initialize; super('items'); end

  def add_item(&block)
    item = AlfredXMLItem.new
    item.instance_eval( &block )
    self << item
  end

  def pretty
    out = ''
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    formatter.write(self, out)
    out
  end

  alias :to_s :pretty

  def self.from_list(arr)
    xml = AlfredXML.new
    arr.each do |item|
      attrs, children = item
      xml.add_item do
        attrs.each {|k, v| attribute(k, v) }
        children.each {|k, v| send(k, v) }
      end
    end
    xml
  end
end

class AlfredXMLItem < Element
  def initialize; super('item'); end
  def title  text
    self << elem_with_text(:title, text)
  end
  def subtitle text
    self << elem_with_text(:subtitle, text)
  end
  def icon text
    self << elem_with_text(:icon, text)
  end
  def attribute(att, value)
    attributes[att.to_s] = value
  end

  private
  def elem_with_text(label, text)
    el = Element.new(label.to_s)
    el.text = text
    el
  end
end
