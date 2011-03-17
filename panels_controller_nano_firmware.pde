/*******************************************************************************
 * panels_controller_nano_firmware.pde
 *
 *
 * Author: Peter Polidoro, IO Rodeo Inc. 02/16/2011
 *******************************************************************************/
#include <Wire.h>
#include <util/atomic.h>

#define GENERAL_CALL_ADDRESS       0
#define INITIAL_PATTERN_BYTE_COUNT 8
#define PATTERN_FRAME_COUNT        4
// Set up timer 2 w/ 1kHz overflow
#define TIMER_TCCR2A 0x03
#define TIMER_TCCR2B 0x0C
#define TIMER_OCR2A 249
#define DFLT_MAX_DELAY_CNT 200

boolean sendFrame = false;
uint8_t delayCnt = 0;
uint8_t maxDelayCnt = DFLT_MAX_DELAY_CNT;
uint8_t frame_n = 0;
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
  // Setup serial communications
  Serial.begin(9600);

  Wire.begin(); // join i2c bus (address optional for master)
  Wire.beginTransmission(GENERAL_CALL_ADDRESS); // transmit to all devices
  Wire.send(INITIAL_PATTERN,INITIAL_PATTERN_BYTE_COUNT);
  Wire.endTransmission();    // stop transmitting

  // Initialize timer 2 
  TCCR2A = TIMER_TCCR2A;
  TCCR2B = TIMER_TCCR2B;
  OCR2A = TIMER_OCR2A;
  // Timer 2 overflow interrupt enable 
  TIMSK2 |= (1<<TOIE2) | (0<<OCIE2A);
  TCNT2 = 0;
}

/*******************************************************************************
 * loop
 *
 *******************************************************************************/
void loop() {
  while (Serial.available() > 0) {
    uint8_t byte = (uint8_t) Serial.read();
    if (byte >= 0) {
      ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        maxDelayCnt = byte;
        delayCnt = 0;
      }
    }
  }
  if ((maxDelayCnt > 0) && (sendFrame == true)) {
    Wire.beginTransmission(GENERAL_CALL_ADDRESS); // transmit to all devices
    Wire.send(PATTERN[frame_n],INITIAL_PATTERN_BYTE_COUNT);
    Wire.endTransmission();    // stop transmitting
    frame_n = (frame_n + 1) % PATTERN_FRAME_COUNT;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) { 
      sendFrame = false;
    }
  }
}


/******************************************************************************
 * Timer 2 overflow interrupt service routine
 *
 ******************************************************************************/
ISR(TIMER2_OVF_vect) {
  delayCnt++;
  if (delayCnt >= maxDelayCnt) {
    delayCnt = 0;
    sendFrame = true;
  }
}
