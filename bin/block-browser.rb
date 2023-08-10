#!/usr/bin/env ruby

require "json"
require "reline"

class Btcctl
  attr_accessor :gopath

  def initialize
    @gopath = `go env GOPATH`.chomp
  end

  def exec(args_str)
    commandline = "#{gopath}/bin/btcctl #{args_str}"
    $stderr.puts(commandline)
    output = IO.popen(commandline, "r", :err=>[:child, :out]) do |f|
      f.read()
    end
  end
end

class Browser
  attr_accessor :btcctl
  attr_accessor :current_block_hash
  attr_accessor :current_block

  def initialize
    @btcctl = Btcctl.new
    select_last_block
  end

  def refresh_view
    puts JSON.pretty_generate(current_block)
  end

  def select_block(hash)
    self.current_block_hash = hash
    current_block_json = btcctl.exec("getblock #{current_block_hash}")
    self.current_block = JSON.parse(current_block_json)
  end

  def select_last_block
    hash = btcctl.exec("getbestblockhash")
    select_block(hash)
  end

  def select_prev_block
    hash = current_block["previousblockhash"]
    if hash.nil? or hash == "0000000000000000000000000000000000000000000000000000000000000000"
      $stderr.puts("no previous block")
    else
      select_block(hash)
    end
  end

  def select_next_block
    hash = current_block["nextblockhash"]
    if hash.nil? or hash == "0000000000000000000000000000000000000000000000000000000000000000"
      $stderr.puts("no next block")
    else
      select_block(hash)
    end
  end

  def run
    prompt = "prompt> "
    use_history = true
    prev_line = "l"

    loop do
      refresh_view
      line = Reline.readline(prompt, use_history)
      line = prev_line if line.empty?
      case line
      when "p"
        prev_line = line
        select_prev_block
      when "n"
        prev_line = line
        select_next_block
      when "l"
        prev_line = line
        select_last_block
      when "q"
        break
      end
    end
  end
end

Browser.new.run
