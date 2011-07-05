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
		when "sc"
				scope.scopewrite([0x3C,0x3C,0x00,0x03,0xF0,0xAA])
				#scope.dataprint scope.debugread
		when "sr"
				scope.dataprint scope.scoperead
		end
end
