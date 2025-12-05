// This example uses an ESP32 Development Board
// to connect to shiftr.io.
//
// You can check on your device after a successful
// connection here: https://www.shiftr.io/try.
//
// by Joël Gähwiler
// https://github.com/256dpi/arduino-mqtt

#include <WiFi.h>
#include <MQTT.h>
#include <LiquidCrystal_I2C.h>

#define LCD_LEN 16

const char ssid[] = "LANTAI 2";
const char pass[] = "FKH070452";
IPAddress address(192,168,110,234);

const char topic[]    = "schedule/class";
const char username[] = "user2";
const char userpass[] = "pass";

WiFiClient net;
MQTTClient client;

LiquidCrystal_I2C lcd(0x27,20,4);

void connect() {
  Serial.print("checking wifi...");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }

  Serial.print("\nconnecting...");
  while (!client.connect("esp32-lcd", username, userpass)) {
    Serial.print(".");
    delay(1000);
  }

  Serial.println("\nconnected!");

  client.subscribe(topic);
}

void messageReceived(String &topic, String &payload) {
  Serial.println("incoming: " + topic + " - " + payload);

  // Note: Do not use the client in the callback to publish, subscribe or
  // unsubscribe as it may cause deadlocks when other things arrive while
  // sending and receiving acknowledgments. Instead, change a global variable,
  // or push to a queue and handle it in the loop after calling `client.loop()`.
  
  int slen = payload.length();
  
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(payload);

  if (slen > LCD_LEN) {
    String subs = payload.substring(LCD_LEN+1);
    lcd.setCursor(0,1);
    lcd.print(subs);
  }
}

void setup() {
  lcd.init();  
  lcd.backlight();

  Serial.begin(115200);
  WiFi.begin(ssid, pass);

  client.begin(address, net);
  client.onMessage(messageReceived);

  connect();
}

void loop() {
  client.loop();
  delay(500);

  if (!client.connected()) {
    connect();
  }
}
