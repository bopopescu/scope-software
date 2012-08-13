module Scope

  module Commands
    SendFrame = 0x90
  end

  module USBCodes
    VID = 0xaaaa
    PID = 0x0005
    TIMEOUT = 300
    OUTEP = 0x01
    INEP = 0x81
    EPLen = 64
  end

  class USBDeviceNotFound < StandardError; end
  class CannotOpenDevice < StandardError; end
  class CannotClaimDevice < StandardError; end
  class CannotClaimInterface < StandardError; end
  class CannotSetAltInterface < StandardError; end
end
