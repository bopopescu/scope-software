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
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "hw1.h"

#define MAX_READ EPDATA_LEN*20

int main(int argc, char** argv)
{
  int ret;

  //Try to get device
  printf("Finding scope device.\n");
  ScopeV1* scope = new ScopeV1();
  ret = scope->setup(0x00F0, true, true); //TODO: allow config from ARGV
  if(ret != 0)
  {
    fprintf(stderr, "Failed to get device: %d\n", ret);
    delete scope;
    return -1;
  }
  printf("Got scope device\n");

  /*//Run scope to get some data in the buffers
  printf("Running scope");
  ret = scope->start();
  if(ret != 0)
  {
    fprintf(stderr, "Failed to start sampling: %d\n", ret);
    delete scope;
    return -2;
  }*/

  for(int i=0; i<100; i++)
  {
    printf(".");
    usleep(10000);
  }

  ret = scope->stop();
  if(ret != 0)
  {
    fprintf(stderr, "Failed to stop sampling: %d\n", ret);
    delete scope;
    return -3;
  }

  printf("Done\n");


  //Get the data from the device
  unsigned char buf[MAX_READ];
  memset(buf, 0, MAX_READ);
  int actual;
  printf("Getting data from buffers\n");
  ret = scope->read(buf, MAX_READ, &actual);
  if(ret != 0 && ret != LIBUSB_ERROR_TIMEOUT)
  {
    fprintf(stderr, "Failed to get data from device\n");
    delete scope;
    return -4;
  }

  printf("Got %d bytes from device\n", actual);

  //Do some processing to get into a sensible form
  int chnlLen = actual;
  if((actual % 2) != 0)
    chnlLen--;

  unsigned char* rawChnlA = (unsigned char*)malloc(chnlLen);
  unsigned char* rawChnlB = (unsigned char*)malloc(chnlLen);
  float* voltChnlA = (float*)malloc(chnlLen * sizeof(float));
  float* voltChnlB = (float*)malloc(chnlLen * sizeof(float));
  if(!rawChnlA || !rawChnlB || !voltChnlA || !voltChnlB)
  {
    fprintf(stderr, "Failed to malloc the channel buffers\n");
    return -5;
  }
  scope->processRawChannels(buf, actual, rawChnlA, rawChnlB);
  scope->processVoltChannel(rawChnlA, chnlLen, voltChnlA);
  scope->processVoltChannel(rawChnlB, chnlLen, voltChnlB);

  //Write out to a csv
  FILE *fd = fopen("data.csv", "w");
  if(!fd)
  {
    fprintf(stderr, "Failed to open file for output data. Check write permissions\n");
    ret = -6;
    goto cleanup;
  }
  ret = fputs("T/clocks,A/mv,B/mv\n", fd);
  if(ret == EOF)
  {
    fprintf(stderr, "Failed to write CSV header\n");
    ret = -7;
    goto cleanup;
  }

  for(int i=0; i<chnlLen; i++)
  {
    ret = fprintf(fd, "%d,%.5f,%.5f", i, voltChnlA[i], voltChnlB[i]);
    if(ret < 0)
    {
      fprintf(stderr, "Failed to write line %d\n",i);
      ret = -8;
      goto cleanup;
    }
  }

  //Clean memory + exit
  ret = 0;
cleanup:
  fclose(fd);
  free(voltChnlA);
  free(voltChnlB);
  free(rawChnlA);
  free(rawChnlB);
  delete scope;
  return ret;
}
