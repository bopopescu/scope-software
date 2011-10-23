require 'rubygems'
require 'usb'
require 'terminal-table/import'
require 'lib/constants'
require 'lib/helpers'

module USBScope
  class Scope
    include USBCodes
    include CONST
    attr_reader :usb_status

    def initialize
      @dev = self.class.getDevice()
      @handle = self.class.getHandle(@dev)
      @usb_status = :connected
    end

    def dataprint(x)
      x.each_byte { |b|
        print b.to_s(16)
      }
      print "\n"
    end

    def debugwrite(cmd)
      begin
        @handle.usb_control_msg(VendorRequestOut, cmd, 0, 0, "", TIMEOUT)
      rescue
        puts "Vendor Command failed - #{$!}"
      end
    end

    def debugread(cmd)
      buffer = ' '*64
      begin
        @handle.usb_control_msg(VendorRequestIn, cmd, 0, 0, buffer, TIMEOUT)
      rescue
        puts "Vendor read failed - timeout - #{$!}"
      end
      return buffer
    end

    def scopewrite(cmd)
      s = cmd.pack("C*")
      s = s + "\000"*(ScopeEPCtrlLen-s.length)
      self.dataprint s
      begin
        @handle.usb_bulk_write(ScopeEPCtrl,s,TIMEOUT)
      rescue
        puts $!
        puts "Write failed - timeout"
      end
    end

    def scoperead()
      buffer = "\000"*ScopeEPDataLen
      begin
        @handle.usb_bulk_read(ScopeEPData,buffer,TIMEOUT)
      rescue
        puts "Read failed - timeout"
      end
      return buffer
    end

    def readep(num,buflen)
      buffer = ' '*buflen
      begin
        @handle.usb_bulk_read(num, buffer, TIMEOUT)
      rescue
        puts "Read failed - timeout"
      end
      return buffer
    end

    def genOut(dest, rw, reg, value)
      [MAGIC, dest, (rw + reg << 1), value]
    end

    def getInfo
      d = debugread(DebugCommands::Info)
      dataprint d
      raise "Received wrong packet - not info" if d[0] != 0x15
      n = ' '
      cs_table = table do |t|
        t.headings = 'Endpoint','Byte Count','STALL','BUSY','EMPTY','FULL','NPAK0','NPAK1','NPAK2'
        t << ['EP1OUT',d[1],bit(d[11],0),bit(d[11],1),n,n,n,n,n]
        t << ['EP1IN',d[2],bit(d[12],0),bit(d[12],1),n,n,n,n,n]
        t << ['EP2',(((d[3]&7)<<8)+d[4]),bit(d[13],0),n,bit(d[13],2),bit(d[13],3),bit(d[13],4),bit(d[13],5),bit(d[13],6)]
        t << ['EP4',(((d[5]&3)<<8)+d[6]),bit(d[14],0),n,bit(d[14],2),bit(d[14],3),bit(d[14],4),bit(d[14],5),n]
        t << ['EP6',(((d[7]&7)<<8)+d[8]),bit(d[13],0),n,bit(d[13],2),bit(d[13],3),bit(d[13],4),bit(d[13],5),bit(d[13],6)]
        t << ['EP8',(((d[9]&3)<<8)+d[10]),bit(d[14],0),n,bit(d[14],2),bit(d[14],3),bit(d[14],4),bit(d[14],5),n]
      end
      puts cs_table

      ep_table = table do |t|
        t.headings = 'Endpoint','VALID','DIR','TYPE1','TYPE0','SIZE','BUF1','BUF0'
        t << ['EP2',bit(d[26],7),bit(d[26],6),bit(d[26],5),bit(d[26],4),bit(d[26],3),bit(d[26],1),bit(d[26],0)]
        t << ['EP4',bit(d[27],7),bit(d[27],6),bit(d[27],5),bit(d[27],4),bit(d[27],3),bit(d[27],1),bit(d[27],0)]
        t << ['EP6',bit(d[28],7),bit(d[28],6),bit(d[28],5),bit(d[28],4),bit(d[28],3),bit(d[28],1),bit(d[28],0)]
        t << ['EP8',bit(d[29],7),bit(d[29],6),bit(d[29],5),bit(d[29],4),bit(d[29],3),bit(d[29],1),bit(d[29],0)]
      end
      puts ep_table

      fifo_table = table do |t|
        t.headings = 'Fifo','Byte Count','InFull-1','OutEmpty-1','AUTOOUT','AUTOIN','ZEROLENIN','WORDWIDE'
        t << ['EP2FIFO',((d[17]<<8)+d[18]),bit(d[30],6),bit(d[30],5),bit(d[30],4),bit(d[30],3),bit(d[30],2),bit(d[30],0)]
        t << ['EP4FIFO',((d[19]<<8)+d[20]),bit(d[31],6),bit(d[31],5),bit(d[31],4),bit(d[31],3),bit(d[31],2),bit(d[31],0)]
        t << ['EP6FIFO',((d[21]<<8)+d[22]),bit(d[32],6),bit(d[32],5),bit(d[32],4),bit(d[32],3),bit(d[32],2),bit(d[32],0)]
        t << ['EP8FIFO',((d[23]<<8)+d[24]),bit(d[33],6),bit(d[33],5),bit(d[33],4),bit(d[33],3),bit(d[33],2),bit(d[33],0)]
      end
      puts fifo_table

      others = table do |t|
        t.headings = 'REG','7','6','5','4','3','2','1','0'
        t << ['FIFORESET',bit(d[34],7),bit(d[34],6),bit(d[34],5),bit(d[34],4),bit(d[34],3),bit(d[34],2),bit(d[34],1),bit(d[34],0)]
        t << ['OUTPKTEND',bit(d[35],7),bit(d[35],6),bit(d[35],5),bit(d[35],4),bit(d[35],3),bit(d[35],2),bit(d[35],1),bit(d[35],0)]
      end
      puts others

    end

    private
    def self.getDevice
      dev = USB.devices.find {|d| d.idVendor == VID and d.idProduct == PID}
      raise USBDeviceNotFound if dev.nil?
      return dev
    end

    def self.getHandle(dev)
      handle = dev.open
      raise CannotOpenDevice if handle.nil?
      begin
        ret = handle.usb_claim_interface(1)
        raise CannotClaimInterface if ret.nil?
      rescue CannotClaimInterface
        handle.usb_detach_kernel_driver_np(1,0)
        handle.usb_claim_interface(1)
        puts "Detaching kernel driver"
      end
      return handle
    end

  end
end
