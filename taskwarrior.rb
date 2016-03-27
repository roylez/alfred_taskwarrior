#!/usr/bin/env ruby
# coding: utf-8
#Description: class for taskwarrior data access

require 'json'
require 'time'

class TaskWarrior
  def initialize(bin = nil)
    @task = bin || "/usr/local/bin/task"
  end

  def json(pattern)
    res = _run("#{pattern} export").chomp.force_encoding('utf-8')
    return nil if res.to_s.empty?
    begin
      JSON.parse res, :symbolize_names => true
    rescue
      res = ( "[" + res.gsub("\n", ",") + "]" )
      JSON.parse res, :symbolize_names => true
    end
  end

  def export(pattern = nil)
    details = json pattern
    details.each{|i|
      [:entry, :due, :modified, :end].each{|k| i[k] = Time.parse(i[k]) if i.key?(k) }
      i[:urgency] = i[:urgency].to_f  if i.key? :urgency
    }
    details.sort!{ |a,b| b[:urgency] <=> a[:urgency] }
  end

  private

  def _run(cmd)
    `#{@task} #{cmd}`
  end
end

if __FILE__ == $0
  t = TaskWarrior.new

  p t.export("status:pending")
end
