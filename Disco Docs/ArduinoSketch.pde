
#define RED 11
#define GREEN 10
#define BLUE 9

void setup()
  {
  Serial.begin(9600);

  pinMode(RED, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BLUE, OUTPUT);
  }
  
void loop()
  {
  if (Serial.available() >= 3)
     {
     analogWrite(RED, Serial.read());
     analogWrite(GREEN, Serial.read());
     analogWrite(BLUE, Serial.read());
     }
  }
