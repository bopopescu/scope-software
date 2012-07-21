from pyBusPirateLite.I2Chigh import *
from pyBusPirateLite.RAW_WIRE import *
from optparse import OptionParser, OptionGroup
import sys

#--------------------------------------------------------------------
#Functions
#--------------------------------------------------------------------

def setDACValue(device, addr, value):
  #Assemble the 2 data bytes
  datahigh = (value >> 6) | 0
  datalow = (value & 0xFF) << 2

  #Send
  bp = I2Chigh(device, 115200, 1)
  bp.BBmode()
  bp.enter_I2C()
  bp.cfg_pins(I2CPins.POWER | I2CPins.PULLUPS)

  bp.send_start_bit()
  stat = bp.bulk_trans(1, [addr<<1 | 0])
  if stat[0] == chr(0x01):
    raise IOError, "DAC didn't ack address and write"
  stat = bp.bulk_trans(1, [datahigh])
  if stat[0] == chr(0x01):
    raise IOError, "DAC didn't ack top bits"
  stat = bp.bulk_trans(1, [datalow])
  if stat[0] == chr(0x01):
    raise IOError, "DAC didn't ack bottom bits"
  bp.send_stop_bit()
  bp.resetBP()


def setLMHOptions(device, lp, highgain, ladder):
  #Assemble the 2 data bytes
  datahigh = 0 | ((lp & 0x04) >> 2)
  datalow = ((lp & 0x03) << 6) | ((highgain & 0x01) << 4) | (ladder & 0x0F)

  #Send
  bp = RAW_WIRE(device, 115200)
  bp.BBmode()
  bp.enter_rawwire()
  bp.raw_cfg_pins(PinCfg.POWER | PinCfg.CS)
  if not bp.cfg_raw_wire((RAW_WIRECfg.BIT_ORDER & RAW_WIRE_BIT_ORDER_TYPE.MSB) |
                         (RAW_WIRECfg.WIRES & RAW_WIRE_WIRES_TYPE.TWO) |
                         (RAW_WIRECfg.OUT_TYPE & RAW_WIRE_OUT_TYPE._3V3)):
    raise IOError, "Failed to set pin type correctly"
  bp.set_speed(RAW_WIRESpeed._400KHZ)
  bp.CS_Low()
  bp.bulk_trans(3, [0x00, datahigh, datalow])
  bp.CS_High()
  bp.resetBP()


#--------------------------------------------------------------------
#Main program routine
#--------------------------------------------------------------------
def main():
  #Parse CLI arguments
  parser = OptionParser()
  parser.add_option("-d", "--device", dest="device", default="/dev/ttyUSB0",
                    help="device name (path or COMx)", metavar="/dev/ttyUSB0")
  parser.add_option("-m", "--mode", dest="mode",
                    help="offset/trig/lmh6518", metavar="offset")
  dacgroup = OptionGroup(parser, "DAC only", "")
  dacgroup.add_option("-v", "--value", dest="value", type="int",
                    help="value for DAC (offset/trig) output", metavar=0x00)
  parser.add_option_group(dacgroup)
  lmhgroup = OptionGroup(parser, "LMH6518 only", "")
  lmhgroup.add_option("-f", "--filter", dest="lp", default=0x00, type="int",
                      help="numeric (3 bit) value to choose filter (Table 6)")
  lmhgroup.add_option("-l", "--ladder", dest="ladder", default=0x00, type="int",
                      help="numeric (4 bit) value to choose ladder (Table 7)")
  lmhgroup.add_option("-H", "--high-gain", action="store_true", dest="highgain",
                      help="Enable to use the high-gain preamp", default=False)
  parser.add_option_group(lmhgroup)

  (options, args) = parser.parse_args()

  #Check sanity of received arguments
  lmhmode = ["lmh6518"]
  dacmode = ["offset", "trig"]
  dacaddr = [0x0D, 0x0C]
  modes = lmhmode + dacmode
  if options.mode not in modes:
    parser.error("Mode argument not known")

  if options.mode in dacmode:
    setDACValue(options.device, dacaddr[dacmode.index(options.mode)],
                options.value)
  elif options.mode in lmhmode:
    setLMHOptions(options.device, options.lp, options.highgain, options.ladder)

if __name__ == "__main__":
  main()
