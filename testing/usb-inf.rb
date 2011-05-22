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
				scope.scopewrite([ScopeCommands::SetClk,0x00,0x1F,0x00,0x00,0x00,0x00,0x00])
		when "r"
				scope.debugwrite([DebugCommands::Refifo,0xA3,0x11])
		when "sr"
				data = scope.scoperead
				out = data.unpack('U'*data.length).collect {|x| x.to_s 16}
				out.each { |i| print i + " " }
				print "\n"
		end
end
