#!/usr/bin/ruby

require 'readline'
require 'lib/scope'
include USBScope

scope = Scope.new

until (action = Readline.readline("?>",true)) == "q"
		case action
		when "l1"
				scope.debugwrite([DebugCommands::LEDOn])
		when "l0"
				scope.debugwrite([DebugCommands::LEDOff])
		when "lb"
				5.times{ 
						scope.debugwrite([DebugCommands::LEDOn])
						sleep(0.3)
						scope.debugwrite([DebugCommands::LEDOff])
						sleep(0.3)
				}
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
		when "d"
				scope.debugwrite([DebugCommands::Destall])
		when "sc"
				scope.scopewrite([0x3C,0x3C,0x03,0x03,0xF0,0xAA])
				#scope.dataprint scope.debugread
		when "r"
				scope.debugwrite([DebugCommands::Refifo,0xA3,0x11])
		when "sr"
				scope.dataprint scope.scoperead
		end
end
