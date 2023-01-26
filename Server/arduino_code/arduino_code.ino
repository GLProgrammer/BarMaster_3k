#include <Adafruit_MotorShield.h>
#include <AccelStepper.h>
#include <Servo.h>

Adafruit_MotorShield AFMS = Adafruit_MotorShield();

Adafruit_StepperMotor *stepperOne = AFMS.getStepper(200, 1);

Servo servoOne;

//Moving stepper using AccelStepper library
void forwardstep1() {
  stepperOne->onestep(FORWARD, DOUBLE);
}
void backwardstep1() {
  stepperOne->onestep(BACKWARD, DOUBLE);
}

AccelStepper accelOne(forwardstep1, backwardstep1);


int running = 1;
int actualButtonStatus = 1;
int buttonPin = 18;

// Function for homing BarMaster
String homeBarBot(){
  accelOne.setMaxSpeed(100.0);
  accelOne.setAcceleration(100.0);
  accelOne.moveTo(5000);

  while(digitalRead(buttonPin)){
    accelOne.run();
  }

  delay(1500);
  accelOne.setCurrentPosition(0);
  return "H200";
}

// Function for rotating to position
String rotateToPosition(int position){
  accelOne.setMaxSpeed(100);
  accelOne.setAcceleration(50);
  accelOne.moveTo((position-1) * 165); //165

  accelOne.runToPosition();
  return "M200";
}

// Function for pouring drinks
String pourDrink(){
   servoOne.write(60);  //80 is dropping water
   servoOne.attach(46);
   delay(6000);
   servoOne.write(180);
   delay(1000);
   servoOne.detach();
   return "P200";
}

// Function for sending terminator
void sendEnding(){
  Serial.write(13);
  Serial.write(10);
}


void setup() {
   pinMode(18,INPUT_PULLUP);

   Serial.begin(115200);
   Serial.print("Connection Started...");
   sendEnding();

  if(!AFMS.begin()){
    Serial.print("S404");
    sendEnding();
    while (1);
  }
  
  // Sending status that BarMaster is ready
  Serial.print("S200");
  sendEnding();
}

char instruction;
int index = 0;

void loop() {
  instruction = "";
  while(Serial.available() > 0){
    instruction = Serial.read();
  }

  switch(instruction){
    case 72:  //Home
      Serial.print(homeBarBot());
      sendEnding();
      break;
    
    case 65:  //Move To position 1
      Serial.print(rotateToPosition(1));
      sendEnding();
      break;

      case 66:  //Move To position 2
      Serial.print(rotateToPosition(2));
      sendEnding();
      break;

      case 67:  //Move To position 3 
      Serial.print(rotateToPosition(3));
      sendEnding();
      break;

      case 68:  //Move To position 4
      Serial.print(rotateToPosition(4));
      sendEnding();
      break;

      case 69:  //Move To position 5
      Serial.print(rotateToPosition(5));
      sendEnding();
      break;

      case 70:  //Move To position 6
      Serial.print(rotateToPosition(6));
      sendEnding();
      break;

      case 80:  //Pour Drink
      Serial.print(pourDrink());
      sendEnding();
      break;
  }
}
