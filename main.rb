#!/usr/bin/env ruby
# coding: utf-8
#Description:

require_relative 'alfred'
require_relative 'taskwarrior'

ENV['TZ'] = 'Asia/Shanghai'

def print_avail_commands
  list = [
    [{:valid => 'no', :autocomplete => "add ", :arg => :add }, {:title => :add, :subtitle => 'add a new task to taskwarrior' } ],
    [{:valid => 'no', :autocomplete => "ls ",  :arg => :ls },  {:title => :ls,  :subtitle => 'list pending tasks' }],
    [{:valid => 'no', :autocomplete => "do ",  :arg => :do },  {:title => :do,  :subtitle => 'mark a task a completed' } ],
  ]
  puts AlfredXML.from_list(list)
end

def tasks_to_items(tasks)
  detail = tasks.collect{|t|
    subtitle = []
    if t[:due]
      due = (t[:due].to_local - Time.now.to_i).to_i
      due = due < 0 ? "-" + format_vague(-1 * due) : format_vague(due)
      subtitle.push("Due:#{due}")
    end
    subtitle.push("Project:#{t[:project]}") if t[:project]
    subtitle.push("Tags:#{t[:tags].join(" ")}") if t[:tags]

    [{:valid => 'yes', :arg => t[:uuid] },
     {:title => t[:description].gsub("\n", '~'),
      :subtitle =>  subtitle.join(" | ")}
      #:icon => t[:due] ? "task_due_#{due_color t[:due]}.png" : "" }
    ]
  }
  AlfredXML.from_list(detail)
end

#def due_color(due_date)
  #require 'date'
  #due = due_date.to_local
  #today = Date.today.to_time
  #tomorrow = Date.today.next.to_time

  #due < today ? 1 : ( due < tomorrow ? 2 : 3)
#end

def format_vague(period)
  ##
  # Shamelessly stolen from
  # https://git.tasktools.org/projects/TM/repos/task/browse/src/ISO8601.cpp
  # formatVague()
  days = period / 86400.0

  case period
  when 1 .. 59
    "#{period}s"
  when 60 .. (3600-1)
    "#{(period / 60.0).round}min"
  when 3600 .. (3600*24-1)
    "#{(period / 3600.0).round}h"
  when (3600*24) .. (3600*24*14-1)
    "#{days.round}d"
  when (3600*24*14) .. (3600*24*90-1)
    "#{(days / 7.0).round}w"
  when (3600*24*90) .. (3600*24*365)
    "#{(days / 30.0).round}mo"
  else
    "#{(days / 365.0).round}y"
  end
end

class Time
  def to_local
    Time.at(to_i)
  end
end

if __FILE__ == $0
  if ARGV.empty?
    print_avail_commands
  else
    cmd  = ARGV.first
    args = ARGV[1..-1]
    t    = TaskWarrior.new
    case cmd
    when 'ls'
      pattern = args.join(" ")
      res = t.export( pattern =~ /status:/ ? pattern : "#{pattern} status:pending")
      puts tasks_to_items(res)
    end
  end
end
