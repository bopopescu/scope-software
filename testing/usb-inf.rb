#!/usr/bin/ruby

require 'readline'
require 'lib/scope'
include USBScope

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
								puts "Failed to getInfo - even with retrying"
						end
				end

    when "dr"
        scope.dataprint scope.readep(0x81,64)
		when "sc"
				scope.scopewrite([0x3C,0x3C,0x03,0x00,0xF0,0xAA]) #note that the scope has byte-order swapped
				#scope.dataprint scope.debugread
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
		end

end
