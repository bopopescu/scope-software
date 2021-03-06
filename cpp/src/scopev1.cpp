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
#include <stdio.h>
#include <libusb.h>
#include "hw1.h"

ScopeV1::ScopeV1()
{
  dev = NULL;
}

ScopeV1::~ScopeV1()
{
  if(dev != NULL)
  {
    libusb_release_interface(dev, 1);
    libusb_close(dev);
  }
  libusb_exit(NULL);
}

int ScopeV1::init()
{
  int ret;

  //Start libusb
  ret = libusb_init(NULL);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to init libusb: %d\n", ret);
    return ret;
  }

  libusb_set_debug(NULL, 3);

  //Get device
  dev = libusb_open_device_with_vid_pid(NULL, SCOPE_VID, SCOPE_PID);
  if(dev == NULL)
  {
    fprintf(stderr, "Failed to find device. Is it plugged in?\n");
    return -1;
  }

  ret = libusb_kernel_driver_active(dev, 1);
  if(ret == 1)
  {
    ret = libusb_detach_kernel_driver(dev, 1);
    if(ret != 0)
    {
      fprintf(stderr, "Failed to detach kernel driver: %d\n", ret);
      return -2;
    }
  }
  else if(ret != 0 && ret != LIBUSB_ERROR_NOT_SUPPORTED)
  {
    fprintf(stderr, "Failed to check if kernel driver was active: %d\n",ret);
    return -3;
  }

  ret = libusb_claim_interface(dev, 1);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to claim required interface: %d\n", ret);
    return -4;
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

  unsigned char usb_buf[EPCTRL_LEN];
  unsigned char cfg_buf[4];
  unsigned char val;
  memset(usb_buf,0,EPCTRL_LEN);

  //Setup channels
  val = 0x00;
  if(chnlA)
    val |= 0x01;
  if(chnlB)
    val |= 0x02;
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
  ret = libusb_bulk_transfer(dev, EPCTRL, usb_buf, 4*3, &actual, USB_TIMEOUT);
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

  unsigned char usb_buf[EPCTRL_LEN];
  unsigned char cfg_buf[4];
  memset(usb_buf,0,EPCTRL_LEN);

  //Setup PD
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_PD, 0, cfg_buf);
  memcpy(usb_buf, cfg_buf, 4);

  //Send config packet
  int actual;
  ret = libusb_bulk_transfer(dev, EPCTRL, usb_buf, 4, &actual, USB_TIMEOUT);
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

  unsigned char usb_buf[EPCTRL_LEN];
  unsigned char cfg_buf[4];
  memset(usb_buf,0,EPCTRL_LEN);

  //Setup PD
  V1Format::genFX2Packet(FMT_DEST_ADC, FMT_WRITE, FMT_REG_PD, 1, cfg_buf);
  memcpy(usb_buf, cfg_buf, 4);

  //Send config packet
  int actual;
  ret = libusb_bulk_transfer(dev, EPCTRL, usb_buf, 4, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to send setup packet: %d\n", ret);
    return -1;
  }


  //Perform a read to ensure this gets received, since the scope checks for config packets, once it stops being stuck waiting for the data
  unsigned char buf[EPDATA_LEN];
  ret = libusb_bulk_transfer(dev, EPDATA, buf, EPDATA_LEN, &actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to read data: %d\n", ret);
    return ret;
  }

  return 0;
}

int ScopeV1::read(unsigned char* buf, int len, int* actual)
{
  int ret;

  if(!dev)
  {
    ret = init();
    if(ret != 0)
      return ret;
  }

  //Perform read(s)
  ret = libusb_bulk_transfer(dev, EPDATA, buf, len, actual, USB_TIMEOUT);
  if(ret != 0)
  {
    fprintf(stderr, "Failed to read data: %d\n", ret);
    return ret;
  }

  return 0;
}

void ScopeV1::processRawChannels(unsigned char* buf, int len, unsigned char *chnlA, unsigned char* chnlB)
{
  for(int i=0; i<len; i++)
  {
    if(i % 2)
      chnlB[i/2] = buf[i];
    else
      chnlA[i/2] = buf[i];
  }
}

void ScopeV1::processVoltChannel(unsigned char* raw, int len, float *volt)
{
  for(int i=0; i<len; i++)
  {
    signed char v = (signed char)raw[i];
    float f = v * 3.3 * 1000 / 255;
    float fin = f / 11.02564103; //INPUT MULTIPLIER
    volt[i] = fin;
  }
}
