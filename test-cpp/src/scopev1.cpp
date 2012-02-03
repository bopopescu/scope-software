/*
 * =====================================================================================
 *
 *       Filename:  scopev1.cpp
 *
 *    Description:  Implement the V1 Scope interface
 *
 *        Created:  03/02/12 22:49:51
 *
 *         Author:  Ali Lown, ali@lown.me.uk
 *
 * =====================================================================================
 */

#include <string.h>
#include <libusb.h>
#include "hw1.h"

ScopeV1::ScopeV1()
{
  ctx = null;
  dev = null;
}

ScopeV1::~ScopeV1()
{
  libusb_exit(ctx);
}

int ScopeV1::init()
{
  int ret;

  //Start libusb
  ret = libusb_init(&ctx);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to init libusb: %d\n", ret);
    return ret;
  }

  libusb_set_debug(ctx, 3);

  //Get device
  dev = libusb_open_device_with_vid_pid(ctx, SCOPE_VID, SCOPE_PID);
  if(!dev)
  {
    fprintf(stderr, "Failed to find device. Is it plugged in?\n");
    return -1;
  }

  return 0;

}

int ScopeV1::setup(unsigned int clk, bool chnlA, bool chnlB)
{
  int ret;

  if(!dev)
  {
    ret = init();
    if(ret != 0)
      return ret;
  }

  unsigned char usb_buf[EPCFG_LEN];
  unsigned char cfg_buf[4];

  //Setup channels
  unsigned char val = chnlA & (chnlB << 1);
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_CHNL, val, cfg_buf);
  memcpy(usb_buf, cfg_buf, 4);

  //Setup clock
  val = clk & 0x00FF;
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_CLKL, val, cfg_buf);
  memcpy(&usb_buf[4], cfg_buf, 4);
  val = (clk & 0xFF00) >> 8;
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_CLKH, val, cfg_buf);
  memcpy(&usb_buf[8], cfg_buf, 4);

  //Send config packet
  int actual;
  ret = libusb_bulk_transfer(dev, EPCFG, usb_buf, 4*3, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to send setup packet: %d\n", ret);
    return -1;
  }

  return 0;
}

int ScopeV1::start()
{
  int ret;

  if(!dev)
  {
    ret = init();
    if(ret != 0)
      return ret;
  }

  unsigned char usb_buf[EPCFG_LEN];
  unsigned char cfg_buf[4];

  //Setup PD
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_PD, 0, cfg_buf);
  memcpy(usb_buf, cfg_buf, 4);

  //Send config packet
  int actual;
  ret = libusb_bulk_transfer(dev, EPCFG, usb_buf, 4, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to send setup packet: %d\n", ret);
    return -1;
  }

  return 0;
}

int ScopeV1::stop()
{
  int ret;

  if(!dev)
  {
    ret = init();
    if(ret != 0)
      return ret;
  }

  unsigned char usb_buf[EPCFG_LEN];
  unsigned char cfg_buf[4];

  //Setup PD
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_PD, 1, cfg_buf);
  memcpy(usb_buf, cfg_buf, 4);

  //Send config packet
  int actual;
  ret = libusb_bulk_transfer(dev, EPCFG, usb_buf, 4, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to send setup packet: %d\n", ret);
    return -1;
  }

  return 0;
}

int ScopeV1::read(unsigned char* buf, int len)
{
  int ret;

  if(!dev)
  {
    ret = init();
    if(ret != 0)
      return ret;
  }

  //Perform read(s)
  int actual;
  ret = libusb_bulk_transfer(dev, EPDATA, buf, len, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to read data: %d\n", ret);
    return -1;
  }

  return 0;
}
