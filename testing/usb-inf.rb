#!/usr/bin/ruby

require 'rubygems'
require 'scruffy'
#require 'Qt4'

require 'readline'

require 'lib/scope'
include USBScope
include CONST

def renorm(x)
  x.to_f/255.0*3.3
end

scope = Scope.new

until (action = Readline.readline("?>",true)) == "q"
  case action
  when "i"
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

  when "dr"
    scope.dataprint scope.readep(0x81,64)
  when "iba"
    #Setup relay, setup mux
    #scope.scopewrite([0xAF,0x10,0x02,0x03,0xAF,0x10,0x20,0x07])
    scope.scopewrite([scope.genOut(DEST_IBA, WRITE, REG_RELAY, 0x03),
                      scope.genOut(DEST_IBA, WRITE, REG_MUX0, 0x07)].flatten)
  when "ibb"
  when "sc"
    #Setup channels, setup clk, setup PD
    #scope.scopewrite([0xAF,0x02,0x08,0x03,    0xAF,0x02,0x04,0xF0,    0xAF,0x02,0x06,0x00,    0xAF,0x02,0x02,0x00])
    scope.scopewrite([scope.genOut(DEST_ADC, WRITE, REG_CHNL, 0x03),
                      scope.genOut(DEST_ADC, WRITE, REG_CLKL, 0xF0),
                      scope.genOut(DEST_ADC, WRITE, REG_CLKH, 0x00),
                      scope.genOut(DEST_ADC, WRITE, REG_PD, 0x00)].flatten)
  when "sr"
    scope.dataprint scope.scoperead
  when "srr"
    File.open("/tmp/tmp/scopeout",'w') do |f|
      begin
        while true
          f.write scope.scoperead
        end
      rescue
        f.close
        puts "ran out of data"
      end
    end
  when "sp"
    t = Time.now
    d = scope.scoperead

    da = []
    db = []
    which = 0;
    d.each_byte do
      |x|
      da.push renorm x if which == 0
      db.push renorm x if which == 1
      which = (which == 0) ? 1 : 0
    end

    g = Scruffy::Graph.new
    g.title = "Scope read at #{t}"
    g.renderer = Scruffy::Renderers::Standard.new
    g.add :line, 'A', da
    g.add :line, 'B', db
    path = "/tmp/tmp/s-#{t.to_i}.svg"
    g.render :to => path

    #app = Qt::Application.new(ARGV)
    #sk = Qt::SvgWidget.new()
    #sk.load(path)
    #sk.show
    #app.exec

  end
end
