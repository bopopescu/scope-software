require 'rubygems'
require 'usb'
require 'terminal-table/import'
require 'constants'

module Scope
  class AnalogDebug
    include USBCodes
    attr_reader :usb_status

    def initialize
      @dev = self.class.getDevice()
      @handle = self.class.getHandle(@dev)
      @usb_status = :connected
    end

    def dataprint(x)
      x.each_byte { |b|
        print b.to_s(16) + " "
      }
      print "\n"
    end

    def write(cmd)
      s = Array.new(EPLen-cmd.length, 0x00)
      s = (cmd + s).pack("C*")
      begin
        @handle.usb_bulk_write(OUTEP, s, TIMEOUT)
      #rescue
      #  puts "Write failed"
      end
    end

    def read
      buf = Array.new(EPLen,0x00).pack("C*")
      puts buf.length
      begin
        @handle.usb_bulk_read(INEP, buf, TIMEOUT)
      #rescue
      #  puts "Read failed"
      end
      return buf
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
      buf = '\x00'*20
      begin
        ret = handle.usb_get_driver_np(0, buf)
        if !ret then
          puts "Detaching kernel driver #{buf}"
          handle.usb_detach_kernel_driver_np(0,0)
        end
      rescue Errno::ENODATA
        #Don't need to remove it
      end
      begin
        ret = handle.usb_set_configuration(1)
        ret = handle.usb_claim_interface(0)
      rescue
        puts "Failed to claim interface"
      end
      return handle
    end

  end
end
