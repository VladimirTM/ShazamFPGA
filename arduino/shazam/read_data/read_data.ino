const int SOUND_INPUT_PIN = A0;

void setup()
{
  pinMode(SOUND_INPUT_PIN, INPUT);
  // make sure to update the BAUD in the console as well   
  Serial.begin(9600);
}

const unsigned int STRING_MAX_SIZE = 200;

void loop()
{
  unsigned short int a = analogRead(SOUND_INPUT_PIN);
  Serial.println(a);
  char *message0 = malloc(sizeof(char) * STRING_MAX_SIZE), *message1 = malloc(sizeof(char) * STRING_MAX_SIZE), *message2 = malloc(sizeof(char) * STRING_MAX_SIZE), *message3 = malloc(sizeof(char) * STRING_MAX_SIZE), *message4 = malloc(sizeof(char) * STRING_MAX_SIZE);
  sprintf(message0, "The number: %d is hex: %x\n", a, a);
  sprintf(message1, "The hex value is: %x, in decimal value: %d. The decimal value is greater than 9: %d, so the ASCII of this hex is: %d, which gets: %c \n", a & 0xF, a & 0xF, (a & 0xF) > 9, (a & 0xF) + (((a & 0xF) > 9) ? 55 : 48), (a & 0xF) + (((a & 0xF) > 9) ? 55 : 48));   
  sprintf(message2, "The hex value is: %x, in decimal value: %d. The decimal value is greater than 9: %d, so the ASCII of this hex is: %d, which gets: %c \n", (a >> 4) & 0xF, (a >> 4) & 0xF, ((a >> 4) & 0xF) > 9, ((a >> 4) & 0xF) + ((((a >> 4) & 0xF) > 9) ? 55 : 48), ((a >> 4) & 0xF) + ((((a >> 4) & 0xF) > 9) ? 55 : 48)); 
  sprintf(message3, "The hex value is: %x, in decimal value: %d. The decimal value is greater than 9: %d, so the ASCII of this hex is: %d, which gets: %c \n", (a >> 8) & 0xF, (a >> 8) & 0xF, ((a >> 8) & 0xF) > 9, ((a >> 8) & 0xF) + ((((a >> 8) & 0xF) > 9) ? 55 : 48), ((a >> 8) & 0xF) + ((((a >> 8) & 0xF) > 9) ? 55 : 48));
  sprintf(message4, "The hex value is: %x, in decimal value: %d. The decimal value is greater than 9: %d, so the ASCII of this hex is: %d, which gets: %c \n", (a >> 12) & 0xF, (a >> 12) & 0xF, ((a >> 12) & 0xF) > 9, ((a >> 12) & 0xF) + ((((a >> 12) & 0xF) > 9) ? 55 : 48), ((a >> 12) & 0xF) + ((((a >> 12) & 0xF) > 9) ? 55 : 48));
  Serial.print(message0);
  Serial.print(message1);
  Serial.print(message2);
  Serial.print(message3);
  Serial.print(message4);
  free(message0);
  free(message1);
  free(message2);
  free(message3);
  free(message4);
}