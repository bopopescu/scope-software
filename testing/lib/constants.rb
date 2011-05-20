module USBScope

		module DebugCommands
				LEDOn = 0x10
				LEDOff = 0x12
				Info = 0x14
				Destall = 0x16
				Refifo = 0x18
		end

		module ScopeCommands
				SetClk = 0xC0
		end

		module USBCodes
				VID = 0xaaaa
				PID = 0x0200
				TIMEOUT = 300
				DebugEPLen = 64
				DebugEPOut = 0x01
				DebugEPIn = 0x81
				ScopeEPCtrlLen = 512
				ScopeEPCtrl = 0x02
				ScopeEPDataLen = 512
				ScopeEPData = 0x86
		end

		class USBDeviceNotFound < StandardError; end
		class CannotOpenDevice < StandardError; end
		class CannotClaimDevice < StandardError; end
		class CannotClaimInterface < StandardError; end
		class CannotSetAltInterface < StandardError; end
end
