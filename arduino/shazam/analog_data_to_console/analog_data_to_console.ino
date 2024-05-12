const int SOUND_INPUT_PIN = A0;
const int MAX_SAMPLE_COUNT = 500;
unsigned short int samples[MAX_SAMPLE_COUNT];
int collected_samples = 0;

void setup()
{
  pinMode(SOUND_INPUT_PIN, INPUT);
  // do not forget to set the BAUD of the serial monitor to 2.000.000 
  Serial.begin(2000000);
}

void print_values () {
  for(int i = 0; i < MAX_SAMPLE_COUNT; i++) {
    Serial.write(((samples[i] >> 12) & 0xF) + (((samples[i] >> 12) & 0xF) > 9 ? 55 : 48));
    Serial.write(((samples[i] >> 8) & 0xF) + (((samples[i] >> 8) & 0xF) > 9 ? 55 : 48));
    Serial.write(((samples[i] >> 4) & 0xF) + (((samples[i] >> 4) & 0xF) > 9 ? 55 : 48));
    Serial.write((samples[i] & 0xF) + ((samples[i] & 0xF) > 9 ? 55 : 48));
    Serial.write(",");
  }
}

void loop()
{
  unsigned short int analogVal;
  if(millis() > 3000) return;
  analogVal = analogRead(SOUND_INPUT_PIN);
  samples[collected_samples] = analogVal;
  collected_samples++;

  if(collected_samples == MAX_SAMPLE_COUNT) {
    print_values();
    collected_samples = 0;
  }
}