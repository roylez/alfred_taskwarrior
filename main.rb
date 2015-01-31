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
    [{:valid => 'yes', :arg => t[:uuid] },
     {:title => t[:description].gsub("\n", '~'),
      :subtitle => t[:due] ? "Due: #{t[:due].to_local.strftime("%Y-%m-%d %H:%M")}  " : "" }
    ]
  }
  AlfredXML.from_list(detail)
end

class Time
  def to_local
    Time.at(to_i)
  end

  def relative
    start_time = to_i
    diff_seconds = Time.now.to_i - start_time
    case diff_seconds
    when 0 .. 10
      "several seconds ago"
    when 11 .. 59
      "#{diff_seconds} seconds ago"
    when 60 .. (3600-1)
      "#{diff_seconds/60} minutes ago"
    when 3600 .. (3600*24-1)
      "#{diff_seconds/3600} hours ago"
    when (3600*24) .. (3600*24*30)
      "#{diff_seconds/(3600*24)} days ago"
    else
      Time.at(start_time).strftime("%Y-%m-%d")
    end
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
