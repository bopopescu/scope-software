/*
 * =====================================================================================
 *
 *       Filename:  hw1.h
 *
 *    Description:  Hardware Revision 1.0 specific includes
 *
 *        Created:  03/02/12 22:25:41
 *
 *         Author:  Ali Lown , ali@lown.me.uk
 *
 * =====================================================================================
 */

#include <libusb.h>

#ifndef HW1_H
#define HW1_H

#define SCOPE_VID       0xaaaa
#define SCOPE_PID       0x0200
#define USB_TIMEOUT     10

#define EPCTRL_LEN      512
#define EPCTRL          0x04
#define EPDATA_LEN      512
#define EPDATA          0x86
#define EPCFG_LEN        512
#define EPCFG           0x88

#define FX2_CMD_INFO    0x14
#define FX2_VEND_IN     0xC0
#define FX2_VEND_OUT    0x40

#define CMD_SETCLK      0xC0

#define FMT_MAGIC       0xAF
#define FMT_DEST_SCOPE  0x01
#define FMT_DEST_ADC    0x02
#define FMT_DST_IBA     0x10
#define FMT_DST_IBB     0x11

#define FMT_REG_IB      0x01
#define FMT_REG_IBA     0x10
#define FMT_REG_IBB     0x11

#define FMT_REG_PD      0x01
#define FMT_REG_CLKL    0x02
#define FMT_REG_CLKH    0x03
#define FMT_REG_CHNL    0x04

#define FMT_REG_RELAY   0x01
#define FMT_REG_MUX0    0x10

#define FMT_READ        1
#define FMT_WRITE       0

class V1Format
{
  public:
  V1Format();

  static void genFX2Packet(unsigned char dest, bool read, unsigned char reg, unsigned char value, unsigned char* buf);
};

class ScopeV1
{
  public:
  ScopeV1();
  ~ScopeV1();

  int init();

  int setup(unsigned int clk, bool chnlA, bool chnlB);
  int start();
  int stop();

  int read(unsigned char* buf, int len, int* actual);

  //chnlA.length + chnlB.length = len. Even split...
  void processRawChannels(unsigned char* buf, int len, unsigned char *chnlA, unsigned char *chnlB);
  void processVoltChannel(unsigned char* raw, int len, float* volt);

  private:
  libusb_device_handle* dev;
};

#endif
