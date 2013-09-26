#include <NewSoftSerial.h>
#include "pitches.h"

//#define DEBUG 1

// Arduino modes
#define OFF 0
#define ON 1
#define CUSTOM 1
#define MANUAL 2
char mode = OFF;

// Sensor information
#define bumpright (sensorbytes[1][0] & 0x01)
#define bumpleft  (sensorbytes[1][0] & 0x02)
#define remote    sensorbytes[2][0]

#define powerButton (sensorbytes[2][1] & 0x08)
#define spotButton (sensorbytes[2][1] & 0x04)
#define cleanButton (sensorbytes[2][1] & 0x02)
#define maxButton (sensorbytes[2][1] & 0x01)

// LEDs
#define greenStatusLed 0x20
#define redStatusLed 0x10
#define maxLed 0x02
#define cleanLed 0x04
#define spotLed 0x08
#define dirtLed 0x01

// NewSoftSerial
int rxPin = 2;
int txPin = 3;
NewSoftSerial sciSerial(rxPin,txPin);

// LED bytes
byte ledValues = 0;
byte pwrLedValue = 0;
byte pwrLedIntensity = 0;

byte vacuumStatus = OFF;
int ddPin = 4;
byte sensorbytes[4][26];

void setup() {

  pinMode(ddPin, OUTPUT);   // sets the pins as output
  sciSerial.begin(57600);
  Serial.begin(9600);

  roombaPowerOn();

  roombaStartMode();
  roombaControlMode();

  //roombaCreateSongs();
  //roombaPlaySong(1);
  mode = CUSTOM;
}

void loop() {
  switch(mode) {
  case OFF:
    Serial.println("OFF MODE");
    break;
  case CUSTOM:
    Serial.println("CUSTOM MODE");
    statusLed();
    updateSensors(0);
    updateSensors(1);
    updateSensors(2);
    updateSensors(3);
/*    if(vacuumStatus == OFF) {
      roombaMotors(0x07);
      delay(500);
      vacuumStatus = ON;
    }*/
    if(bumpleft) {
      roombaSpinRight();
      delay(1000);
    }
    else if(bumpright) {
      roombaSpinLeft();
      delay(1000);
    }
    //roombaGoForward();
    roombaUpdateLeds();
    checkButtons(); // This needs to happen last unless we use an if with a return value and a break
    break;
  case MANUAL:
    Serial.println("MANUAL MODE");
    break;
  default:
    break;
  }
}



//Flashes onboard LED periodically without using DELAY
void statusLed() {

  //LED settings
  long ledInterval = 500; // interval at which to blink (milliseconds)
  static long ledPreviousMillis = 0; // keep track of the last flash of the LED

  if (millis() - ledPreviousMillis > ledInterval) {
    // save the last time you blinked the LED 
    ledPreviousMillis = millis();   

    // if the LED is off turn it on and vice-versa:
    ledValues = ledValues ^ greenStatusLed;
  }
}
void updateSensors(byte bank) {
  sciSerial.print(142, BYTE);
  sciSerial.print(bank,   BYTE);  // sensor packet 1, 10 bytes
  delay(100); // wait for sensors
  char i = 0;
  while(sciSerial.available()) {
    int c = sciSerial.read();
    sensorbytes[bank][i++] = c;
  }
  if(bank == 0 && i != 26)
  {
     Serial.print("Error: only ");
     Serial.print(i, DEC);
     Serial.println(" bytes");
  }
#ifdef DEBUG
  Serial.print("Sensor bank ");
  Serial.print(bank, DEC);
  Serial.print(": i=");
  Serial.println(i, DEC);
  for(int j=0;j<i;j++)
    Serial.println(sensorbytes[bank][i],HEX);
#endif
}
void checkButtons() {
  if(powerButton) {
    roombaPowerOff();
    mode = OFF;
  }
  else if(spotButton && cleanButton) {
    roombaDock();
    mode = MANUAL;
  }
  else if(maxButton) {
    roombaMax();
    mode = MANUAL;
  }
  else if(cleanButton) {
    roombaClean();
    mode = MANUAL;
  }
  else if(spotButton) {
    roombaSpot();
    mode = MANUAL;
  }
  else {
  }
}





void roombaCreateSongs() {
  sciSerial.print(140, BYTE);
  sciSerial.print(0, BYTE);
  sciSerial.print(8, BYTE);

  sciSerial.print(NOTE_C4, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(NOTE_G3, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_G3, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_A3, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(NOTE_G3, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(REST, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(NOTE_B3, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(NOTE_C4, BYTE);
  sciSerial.print(16, BYTE);
  delay(20);


  sciSerial.print(140, BYTE);
  sciSerial.print(1, BYTE);
  sciSerial.print(16, BYTE);

  sciSerial.print(NOTE_A4, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_G4, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_G4, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_G4, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_A4, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_D5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_E5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_F5, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_E5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_D5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_C5, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_D5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_E5, BYTE);
  sciSerial.print(8, BYTE);
  sciSerial.print(NOTE_D5, BYTE);
  sciSerial.print(64, BYTE);
  sciSerial.print(NOTE_C5, BYTE);
  sciSerial.print(16, BYTE);
  sciSerial.print(NOTE_B4, BYTE);
  sciSerial.print(16, BYTE);
}
void roombaPlaySong(byte song) {
  sciSerial.print(141, BYTE);  // PLAY SONG
  sciSerial.print(song, BYTE);  // PLAY SONG ZERO 
}
void roombaDock() {
  Serial.println("roombaDock()");
  roombaClean();
  delay(3000);
  sciSerial.print(143, BYTE);
}
void roombaMax() {
  Serial.println("roombaMax()");
  sciSerial.print(136, BYTE);
  delay(50);
}
void roombaClean() {
  Serial.println("roombaClean()");
  sciSerial.print(135, BYTE);
  delay(50);
}
void roombaSpot() {
  Serial.println("roombaSpot()");
  sciSerial.print(134, BYTE);
  delay(50);
}
void roombaPowerOff() {
  Serial.println("roombaPowerOff()");
  sciSerial.print(133, BYTE);
}
void roombaPowerOn() {
 Serial.println("roombaPowerOn()");  
  digitalWrite(ddPin, HIGH);
  delay(100);
  digitalWrite(ddPin, LOW);
  delay(500);
  digitalWrite(ddPin, HIGH);
  delay(1000); //was 2000?
}
void roombaStartMode() {
  // set up ROI to receive commands
  Serial.println("roombaStartMode()");
  sciSerial.print(128, BYTE);  // START
  delay(50);
}
void roombaControlMode() {
  Serial.println("roombaControlMode()");
  sciSerial.print(130, BYTE);  // CONTROL
  delay(50);
}
void roombaFullMode() {
  Serial.println("roombaFullMode()");
  sciSerial.print(132, BYTE);  // FULL
  delay(50);
}
void roombaUpdateLeds() {
  //Serial.println("roombaUpdateLeds()");
  // set the LED with the ledState of the variable:
  sciSerial.print(139, BYTE);
  sciSerial.print(ledValues, BYTE);
  sciSerial.print(pwrLedValue, BYTE);
  sciSerial.print(pwrLedIntensity, BYTE);
}

void roombaGoForward() {
  Serial.println("roombaGoForward()");
  sciSerial.print(137, BYTE);   // DRIVE
  sciSerial.print(0x00,BYTE);   // 0x00c8 == 200
  sciSerial.print(0xc8,BYTE);
  sciSerial.print(0x80,BYTE);
  sciSerial.print(0x00,BYTE);
}
void roombaGoBackward() {
  sciSerial.print(137, BYTE);   // DRIVE
  sciSerial.print(0xff,BYTE);   // 0xff38 == -200
  sciSerial.print(0x38,BYTE);
  sciSerial.print(0x80,BYTE);
  sciSerial.print(0x00,BYTE);
}
void roombaSpinLeft() {
  sciSerial.print(137, BYTE);   // DRIVE
  sciSerial.print(0x00,BYTE);   // 0x00c8 == 200
  sciSerial.print(0xc8,BYTE);
  sciSerial.print(0x00,BYTE);
  sciSerial.print(0x01,BYTE);   // 0x0001 == spin left
}
void roombaSpinRight() {
  sciSerial.print(137, BYTE);   // DRIVE
  sciSerial.print(0x00,BYTE);   // 0x00c8 == 200
  sciSerial.print(0xc8,BYTE);
  sciSerial.print(0xff,BYTE);
  sciSerial.print(0xff,BYTE);   // 0xffff == -1 == spin right
}
void roombaMotors(byte select) {
  sciSerial.print(138,BYTE);
  sciSerial.print(select,BYTE);
}









