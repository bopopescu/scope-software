/*
 * =====================================================================================
 *
 *       Filename:  v1format.cpp
 *
 *    Description:  Implement the V1 protocol specific helper functions
 *
 *        Created:  03/02/12 23:01:36
 *
 *         Author:  Ali Lown, ali@lown.me.uk
 *
 * =====================================================================================
 */
#include "hw1.h"

V1Format::V1Format()
{
}

void V1Format::genFX2Packet(unsigned char dest, bool read, unsigned char reg, unsigned char value, unsigned char* buf)
{
  buf[0] = FMT_MAGIC;
  buf[1] = dest;
  buf[2] = (read? FMT_READ : FMT_WRITE) | (reg << 1);
  buf[3] = value;
}
