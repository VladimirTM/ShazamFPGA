#include <SPI.h>

#include <SPI.h>
#include <SD.h>
#include <pins_arduino.h>

volatile byte byte1_from_FPGA;
volatile byte byte2_from_FPGA;
volatile byte byte_from_FPGA;

volatile boolean dataReceived;
int byte_count = 0;

void setup()
{
  Serial.begin(2000000);
  pinMode(MISO, OUTPUT);
  SPCR |= _BV(SPE);
  SPCR |= _BV(SPIE);
  SPI.attachInterrupt();
  dataReceived = false;
}

ISR(SPI_STC_vect)
{
  byte_from_FPGA = SPDR;
  dataReceived = true;
}

uint16_t frequency;

void loop()
{
  if(dataReceived) {
    if(byte_count == 0) {
      byte1_from_FPGA = byte_from_FPGA;
      byte_count = 1;
    }
    if(byte_count == 1) {
      byte2_from_FPGA = byte_from_FPGA;
      byte_count = 0;
    }

    if(byte_count == 1) {
      frequency = (byte_2_from_FPGA << 8) | byte_1_from_FPGA;
      Serial.println(frequency);
    }
    dataReceived = false;
  }
}