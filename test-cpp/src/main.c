/*
 * =====================================================================================
 *
 *       Filename:  main.c
 *
 *    Description:  Main file for the scope sw thing
 *
 *        Created:  03/02/12 22:33:07
 *       Compiler:  gcc
 *
 *         Author:  Ali Lown, ali@lown.me.uk
 *
 * =====================================================================================
 */
#include <stdio.h>
#include <unistd.h>
#include "hw1.h"

#define MAX_READ EPDATA_LEN*20

ScopeV1 scope;

int main(char* argv, int argc)
{
  int ret;

  //Try to get device
  printf("Finding scope device.\n");
  scope = new ScopeV1();
  ret = scope.setup(0x00F0, true, true); //TODO: allow config from ARGV
  if(ret != 0)
  {
    fprintf(stderr, "Failed to get device: %d\n", ret);
    return -1;
  }
  printf("Got scope device\n");

  //Run scope to get some data in the buffers
  printf("Running scope");
  ret = scope.start();
  if(ret != 0)
  {
    fprintf(stderr, "Failed to start sampling: %d\n", ret);
    return -2;
  }

  for(int i=0; i<100; i++)
  {
    printf(".");
    usleep(10000);
  }

  ret = scope.stop();
  if(ret != 0)
  {
    fprintf(stderr, "Failed to stop sampling: %d\n", ret);
    return -3;
  }

  printf("Done\n");


  //Get the data from the device
  unsigned char buf[MAX_READ];
  int actual;
  printf("Getting data from buffers\n");
  ret = scope.read(buf, MAX_READ, &actual);
  if(ret != 0 && ret != LIBUSB_ERROR_TIMEOUT)
  {
    fprintf(stderr, "Failed to get data from device\n");
    return -4;
  }

  printf("Got %d bytes from device\n", actual);

  //Do some processing to get into a sensible form

  return 0;
}
