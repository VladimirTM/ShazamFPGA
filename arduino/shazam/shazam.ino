#include "arduinoFFT.h"

int analogPin = A0;   // KY-037 analog interface
int analogVal;        // analog readings
const uint16_t samples = 128; //This value MUST ALWAYS be a power of 2
const float samplingFrequency = 512;
const uint8_t amplitude = 1000;
float values[samples];

// read and save data from sensor

void readSave()
{
  int i = 0;
  while(i < samples)
  {
    analogVal = analogRead(analogPin);
    values[i] = analogVal;
    i++;
  }
}


float vImag[samples] = {0};

ArduinoFFT<float> FFT = ArduinoFFT<float>(values, vImag, samples, samplingFrequency); /* Create FFT object */

void FFTProcessing()
{
  FFT.windowing(FFTWindow::Hamming, FFTDirection::Forward);	/* Weigh data */
  FFT.compute(FFTDirection::Forward); /* Compute FFT */
  FFT.complexToMagnitude(); /* Compute magnitudes */
}

// Constelation Map

int m[4], max;

void constelation()
{
  int maxIndex;
  for(int i = 0; i < 4; i++)
  {
    maxIndex = 0;
    max = 0;
    for(int j = 64 * i; j < 64 * (i + 1); j++)
    {
      if(max < values[j] && (j * (samplingFrequency/samples) > 20))
      {
        max = values[j];
        maxIndex = j * (samplingFrequency/samples);
      }
    }
    m[i] = maxIndex;
  }
}

// Fingerprint

int FUZ_FACTOR = 2;

long hash(int p1, int p2, int p3, int p4) {
  Serial.print(p1);
  Serial.print(" ");
  Serial.print(p2);
  Serial.print(" ");
  Serial.print(p3);
  Serial.print(" ");
  Serial.println(p4);
    return (p4 - (p4 % FUZ_FACTOR)) * 100000000 + (p3 - (p3 % FUZ_FACTOR)) * 100000 + (p2 - (p2 % FUZ_FACTOR)) * 100 + (p1 - (p1 % FUZ_FACTOR));
}

// write data to file

// One frame process

void process()
{
   readSave();
   FFTProcessing();
   constelation();
   long id = hash(m[0], m[1], m[2], m[3]);
   Serial.println(id);
}

void setup()
{
  pinMode(analogPin, INPUT);
  Serial.begin(9600);
  //process();
}

void loop()
{
  process();
}