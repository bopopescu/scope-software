module USBScope

  module DebugCommands
    Info = 0x14
  end

  module ScopeCommands
    SetClk = 0xC0
  end

  module USBCodes
    VID = 0xaaaa
    PID = 0x0200
    TIMEOUT = 300
    ScopeEPCtrlLen = 512
    ScopeEPCtrl = 0x04
    ScopeEPDataLen = 512
    ScopeEPData = 0x86
    ScopeEPCFG = 0x88

    VendorRequestOut = 0x40
    VendorRequestIn = 0xC0
  end

  module CONST
    MAGIC = 0xAF
    DEST_SCOPE = 0x01
    DEST_ADC = 0x02
    DEST_IBA = 0x10
    DEST_IBB = 0x11

    REG_IB = 0x01
    REG_IBA = 0x10;
    REG_IBB = 0x11;

    REG_PD = 0x01
    REG_CLKL = 0x02
    REG_CLKH = 0x03
    REG_CHNL = 0x04

    REG_RELAY = 0x01
    REG_MUX0 = 0x10

    READ = 1
    WRITE = 0
  end

  class USBDeviceNotFound < StandardError; end
  class CannotOpenDevice < StandardError; end
  class CannotClaimDevice < StandardError; end
  class CannotClaimInterface < StandardError; end
  class CannotSetAltInterface < StandardError; end
end
