const int SOUND_INPUT_PIN = A0;

void setup()
{
  pinMode(SOUND_INPUT_PIN, INPUT);
  // make sure to update the BAUD in the console as well   
  Serial.begin(2000000);
}

void loop() {
    Serial.write(analogRead(SOUND_INPUT_PIN));
}