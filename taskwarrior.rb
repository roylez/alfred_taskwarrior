#!/usr/bin/env ruby
# coding: utf-8
#Description: class for taskwarrior data access

require 'json'
require 'time'

class TaskWarrior
  def initialize(bin = nil)
    @task = bin || "/usr/local/bin/task"
  end

  def run(cmd)
    `#{@task} #{cmd}`
  end

  def export(pattern = nil)
    details = JSON.parse( ("[" + run("#{pattern} export") + "]").force_encoding('UTF-8'),
                         :symbolize_names => true)
    details.each{|i|
      [:entry, :due, :modified, :end].each{|k| i[k] = Time.parse(i[k]) if i.key?(k) }
      i[:urgency] = i[:urgency].to_f  if i.key? :urgency
    }
  end
end

if __FILE__ == $0
  t = TaskWarrior.new

  p t.export("status:pending")
end
