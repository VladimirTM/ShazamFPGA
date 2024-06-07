const int SOUND_INPUT_PIN = A0;

void setup() {
  pinMode(SOUND_INPUT_PIN, INPUT);
  // do not forget to set the BAUD of the serial monitor to 2.000.000 
  Serial.begin(2000000);
}

void loop() {
  Serial.write(analogRead(SOUND_INPUT_PIN));
}