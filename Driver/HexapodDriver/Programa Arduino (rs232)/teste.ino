/*
  DigitalReadSerial
 Reads a digital input on pin 2, prints the result to the serial monitor 
 
 This example code is in the public domain.
 */

char c = ' ';
int count = 0;

#define DIST (1 + (int)(0xFF & 'z') - (int)(0xFF & 'a'))

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
}

// the loop routine runs over and over again forever:
void loop() {
  // print out the state of the button:
  if (count < DIST) {
    int x = ((0xFF&c) + count);
    if (x > (0xFF&'z')) x = x - DIST ;
    Serial.write((char)x);
    count ++;
  }
  delay(10);        // delay in between reads for stability
}

void serialEvent(){
  c = Serial.read();
  count = 0;
}

