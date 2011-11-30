#!/usr/bin/ruby

require 'rubygems'
require 'scruffy'
require 'Qt4'

require 'readline'

require 'lib/scope'
include USBScope
include CONST

def renorm(x)
  x.to_f/255.0*3.3
end

def getInfo
  i = 0
  begin
    scope.getInfo
  rescue
    if i < 3 then
      i += 1
      retry
    else
      puts "Failed to getInfo - even with retrying - #{$!}"
    end
  end
end

def dataread
  scope.dataprint scope.readep(0x81,64)
end

def testib
  scope.scopewrite([scope.genOut(DEST_SCOPE, READ, REG_IB, 0x00),
                   scope.genOut(DEST_SCOPE, READ, REG_IBA, 0x00),
                   scope.genOut(DEST_SCOPE, READ, REG_IBB, 0x00)].flatten)
  scope.dataprint scope.readep(USBCodes::ScopeEPCFG, 512)
end

def ibainit
  #Setup relay, setup mux
  scope.scopewrite([scope.genOut(DEST_IBA, WRITE, REG_RELAY, 0x03),
                   scope.genOut(DEST_IBA, WRITE, REG_MUX0, 0x07)].flatten)
end

def scopeinit
  #Setup channels, setup clk, setup PD
  scope.scopewrite([scope.genOut(DEST_ADC, WRITE, REG_CHNL, 0x03),
                   scope.genOut(DEST_ADC, WRITE, REG_CLKL, 0xF0),
                   scope.genOut(DEST_ADC, WRITE, REG_CLKH, 0x00),
                   scope.genOut(DEST_ADC, WRITE, REG_PD, 0x00)].flatten)
end

def stop
  scope.scopewrite(scope.genOut(DEST_ADC, WRITE, REG_PD, 0x01))
end

def start
  scope.scopewrite(scope.genOut(DEST_ADC, WRITE, REG_PD, 0x00))
end

def scoperead
  scope.dataprint scope.scoperead
end

def scoperepread
  File.open("/tmp/scopeout",'w') do |f|
    begin
      while true
        f.write scope.scoperead
      end
    rescue
      f.close
      puts "ran out of data"
    end
  end
end

def scoperepread2
  File.open("/tmp/scopeouta","w") do |fa|
    File.open("/tmp/scopeoutb","w") do |fb|
      begin
        1000.times do
          d = scope.scoperead
          which = 0;
          d.each_char do
            |x|
            if which == 0 then
              fa.write x + "\n"
              which = 1
            else
              fb.write x + "\n"
              which = 0
            end
          end
        end
      rescue
        puts "ran out of data"
        puts $!
      end
    end
  end
end

def processAction(action)
  case action
  when "i"
    getInfo
  when "dr"
    dataread
  when "si"
    testib
  when "iba"
    ibainit
  when "sc"
    scopeinit
  when "stop"
    stop
  when "start"
    start
  when "sr"
    scoperead
  when "srr"
    scoperepread
  when "sr2"
    scoperepread2
  end
end


###############################################################################
###############################################################################

scope = Scope.new
if ARGV.length > 0 then
  processAction ARGV[0]
else
  until (action = Readline.readline("?>",true)) == "q"
    processAction action
  end
end
