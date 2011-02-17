/*******************************************************************************
 * panels_controller_nano_firmware.pde
 *
 *
 * Author: Peter Polidoro, IO Rodeo Inc. 02/16/2011
 *******************************************************************************/
#include <Wire.h>

#define GENERAL_CALL_ADDRESS       0
#define INITIAL_PATTERN_BYTE_COUNT 8
#define PATTERN_FRAME_COUNT        4
#define PATTERN_FRAME_DELAY        200

unsigned char INITIAL_PATTERN[INITIAL_PATTERN_BYTE_COUNT] =              {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
unsigned char ALL_OFF_PATTERN[INITIAL_PATTERN_BYTE_COUNT] =              {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
unsigned char ALL_ON_PATTERN[INITIAL_PATTERN_BYTE_COUNT] =               {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
unsigned char PATTERN[PATTERN_FRAME_COUNT][INITIAL_PATTERN_BYTE_COUNT] = {{0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33},
                                                                          {0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99},
                                                                          {0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCC},
                                                                          {0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66}};

/*******************************************************************************
 * setup
 *
 *******************************************************************************/
void setup() {
  Wire.begin(); // join i2c bus (address optional for master)
  Wire.beginTransmission(GENERAL_CALL_ADDRESS); // transmit to all devices
  Wire.send(INITIAL_PATTERN,INITIAL_PATTERN_BYTE_COUNT);
  Wire.endTransmission();    // stop transmitting
  delay(3000);
}

/*******************************************************************************
 * loop
 *
 *******************************************************************************/
int frame_n = 0;
void loop() {
  Wire.beginTransmission(GENERAL_CALL_ADDRESS); // transmit to all devices
  Wire.send(PATTERN[frame_n],INITIAL_PATTERN_BYTE_COUNT);
  Wire.endTransmission();    // stop transmitting
  delay(PATTERN_FRAME_DELAY);
  frame_n = (frame_n + 1) % PATTERN_FRAME_COUNT;
}
