#include <SPI.h>
#include <SD.h>
#include <pins_arduino.h>

volatile byte byte_from_FPGA;
volatile boolean dataReceived;

void setup()
{
  Serial.begin(2000000);
  pinMode(MISO, OUTPUT);
  SPCR |= _BV(SPE);
  SPCR |= _BV(SPIE);
  SPI.attachInterrupt();
  SPI.setBitOrder(MSBFIRST);
  dataReceived = false;
}

ISR(SPI_STC_vect)
{
  byte_from_FPGA = SPDR;
  Serial.write(byte_from_FPGA);
}
void loop() {}