/*******************************************************************************
 * panels_controller_nano_firmware.pde
 *
 * Setup, loop, and timer interrupt functions for gap crossing control interface
 * firmware.
 *
 * Author: Peter Polidoro, IO Rodeo Inc. 02/16/2011
 *******************************************************************************/
/* #include "msgreader.h"  */
/* #include "diohandler.h" */
#include <Wire.h>

/* MsgReader msgReader; */
/* DioHandler dioHandler; */

#define GENERAL_CALL_ADDRESS        0
#define INITIAL_PATTERN_BYTE_NUMBER 8
unsigned char INITIAL_PATTERN[INITIAL_PATTERN_BYTE_NUMBER] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};     /* count */
unsigned char ALL_OFF_PATTERN[INITIAL_PATTERN_BYTE_NUMBER] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};   /* all off */
unsigned char ALL_ON_PATTERN[INITIAL_PATTERN_BYTE_NUMBER] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};   /* all on */


/*******************************************************************************
 * setup
 *
 * Initializes msgReader (serial communications) and dioaHandeler (ldigital IO
 * & timers).
 *******************************************************************************/
void setup() {
  /* msgReader.initSerial(); */
  /* dioHandler.initDio(); */
  Wire.begin(); // join i2c bus (address optional for master)
  Wire.beginTransmission(GENERAL_CALL_ADDRESS); // transmit to all devices
  Wire.send(INITIAL_PATTERN,INITIAL_PATTERN_BYTE_NUMBER);
  Wire.endTransmission();    // stop transmitting
  delay(3000);
}

/*******************************************************************************
 * loop
 *
 * Communications loop - the msgReader reads two byte messages from the serial
 * interface. Messages have the following form:
 *
 * byte0 = command ID #
 * byte1 = command value
 *
 * When the msgReader has aquired a message it is passed to the dioHander which
 * takes action based on the message.
 *******************************************************************************/
int cycle_n = 0;
int panel_count = 3;
void loop() {
  /* msgReader.readMsg(); */
  /* if (msgReader.hasMsg == true) { */
  /*   MsgData msg = msgReader.getMsg(); */
  /*   dioHandler.handleMsg(msg); */
  /* } */
  /* msgReader.sleep(); */
  for(int panel_n=1;panel_n<=panel_count; panel_n++) {
    Wire.beginTransmission(panel_n); // transmit to device n
    if (cycle_n%2 == 0) {
      Wire.send(ALL_ON_PATTERN,INITIAL_PATTERN_BYTE_NUMBER);
    } else {
      Wire.send(ALL_OFF_PATTERN,INITIAL_PATTERN_BYTE_NUMBER);
    }
    Wire.endTransmission();    // stop transmitting
    delay(1000);
  }
  cycle_n++;
}

/*******************************************************************************
 * IST(TIMER2_OVF_vect)
 *
 * Timer 2 overflow interrupt service function - used for timing the stimulus
 * pulses.
 *******************************************************************************/
/* ISR(TIMER2_OVF_vect) { */
/*     dioHandler.stimPulseTimer(); */
/* } */

/*******************************************************************************
 * ISR(TIMER1_OVF_vect)
 *
 * Timer 1 overflow interrupt service function - used for timing the motor
 * command pulses. Sets pulses low after a short period of time set by the value
 * of MOTOR_CMD_PULSE_T (ms)
 *******************************************************************************/
/* ISR(TIMER1_OVF_vect) { */
/*     dioHandler.motorCmdTimer(); */
/* } */
