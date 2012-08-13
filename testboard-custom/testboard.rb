#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'analogdebug'

include Scope

def dp(x)
  x.each { |b|
    print b.to_s(16) + " "
  }
  print "\n"
end


#Define options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: testboard.rb [options]"
  opts.separator "Common options:"
  opts.on("-m", "--mode [MODE]", [:offset, :trig, :lmh6518], "Mode (offset/trig/lmh6518)") do |m|
    options[:mode] = m
  end
  opts.separator ""
  opts.separator "DAC only options:"
  opts.on("-v", "--value [VALUE]", OptionParser::DecimalInteger, "10bit value for DAC") do |v|
    options[:value] = v
  end
  opts.separator ""
  opts.separator "LMH6518 only options:"
  opts.on("-f", "--filter [FILTER]", OptionParser::DecimalInteger, "3bit value for filter (Table 6)") do |f|
    options[:filter] = f
  end
  opts.on("-l", "--ladder [LADDER]", OptionParser::DecimalInteger, "4bit value for ladder (Table 7)") do |l|
    options[:ladder] = l
  end
  opts.on("-g", "--[no-]gain", "(No) pre-amp high gain") do |g|
    options[:gain] = g
  end
  opts.on("-a", "--[no-]aux", "(No) auxilary output") do |a|
    options[:aux] = a
  end
end.parse!

p options

dacmode = [:offset, :trig]

#Connect to board
board = AnalogDebug.new

def readDAC(board, addr)
  packet = [0x80, addr]
  board.write packet
  dp packet
  data = board.read.unpack("C*")
  dp data
  if data[0] == 0x81 then
    value = (data[2] << 8) | data[1]
    puts "DAC: #{value}"
  else
    puts "Received wrong packet"
  end
end

#Check option combinations are valid + send
if dacmode.include?(options[:mode]) then
  unless options.include?(:value) then
    puts "When DAC, need value"
    exit 1
  end

  addr = 0x0D if options[:mode] == :offset
  addr = 0x0C if options[:mode] == :trig

  puts "Currently:"
  readDAC(board, addr)

  #Send new
  puts "Sending new:"
  packet = [0x82, addr, options[:value] & 0xFF, (options[:value]>>8) & 0x03]
  dp packet
  board.write packet

  puts "Now:"
  readDAC(board, addr)
else
  unless options.include?(:filter) then
    puts "When LMH6518, need filter"
    exit 1
  end
  unless options.include?(:ladder) then
    puts "When LMH6518, need ladder"
    exit 1
  end
  unless options.include?(:gain) then
    puts "When LMH6518, need gain"
    exit 1
  end
  unless options.include?(:aux) then
    puts "When LMH6518, need aux"
    exit 1
  end

  #Read existing
  puts "Currently:"
  packet = "\x84"
  board.write packet
  dp packet
  data = board.read
  dp data
  if data[0] == "\x85" then
    reg = (data[2] + data[1]).unpack("S").shift
    if reg[10] == 1 then
      puts "Power: auxilary hi-z"
    else
      puts "Power: full"
    end
    filter = ["full", "20", "100", "200", "350", "650", "750", "x"]
    puts "Filter: #{filter[(reg >> 6) & 0x07]}"
    if reg[4] == 1 then
      puts "Pre-amp: high gain"
    else
      puts "Pre-amp: low gain"
    end
    ladder = ["0", "-2", "-4", "-6", "-8", "-10", "-12", "-14", "-16", "-18", "-20", "x", "x", "x", "x", "x"]
    puts "Ladder: #{ladder[reg & 0x0F]}"
  else
    puts "Received wrong packet"
  end


  #Send new
  puts "Sending new:"
  data = 0
  if options[:aux] == 1 then
    data = data | (1 << 10)
  end
  if options[:gain] == 1 then
    data = data | (1 << 4)
  end
  data = data | ((options[:filter] & 0x07) << 6)
  data = data | (options[:ladder] & 0x04)
  packet = "\x86#{(data & 0xFF).chr}#{((data >> 8) & 0xFF).chr}"
  board.write packet
  dp packet
end

