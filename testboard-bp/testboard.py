from pyBusPirateLite.I2Chigh import *
from pyBusPirateLite.RAW_WIRE import *
from optparse import OptionParser, OptionGroup
import sys

#--------------------------------------------------------------------
#Functions
#--------------------------------------------------------------------

def setDACValue(addr, value):
  pass

def setLMHOptions(lp, highgain, ladder):
  pass

#--------------------------------------------------------------------
#Main program routine
#--------------------------------------------------------------------
def main():
  #Parse CLI arguments
  parser = OptionParser()
  parser.add_option("-d", "--device", dest="device", default="/dev/ttyUSB0",
                    help="device name (path or COMx)", metavar="/dev/ttyUSB0")
  parser.add_option("-m", "--mode", dest="mode", default="offset",
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
    setDACValue(dacaddr[dacmode.index(options.mode)], options.value)
  elif options.mode in lmhmode:
    setLMHOptions(options.lp, options.highgain, options.ladder)

if __name__ == "__main__":
  main()
