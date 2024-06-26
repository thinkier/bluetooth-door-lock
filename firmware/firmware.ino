#include <bluefruit.h>
#include <Adafruit_LittleFS.h>
#include <InternalFileSystem.h>

#include <Adafruit_TinyUSB.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include "BLETps.h"

#define LOCKED  1575
#define UNLOCKED  2300
#define SERVO_FREQ 50
#define SERVO_NUM 0

#define SERVO_LOCKED_THRESHOLD 410

#define TX_POWER -12

#define SERVO_FEEDBACK A1
#define HALL_SENSOR A0

// BLE Service
BLEUart bleuart; // uart over ble
BLETps bletps(TX_POWER);

Adafruit_PWMServoDriver servo = Adafruit_PWMServoDriver();

// org.bluetooth.service.binary_sensor
BLEUuid bluelockId = BLEUuid(0x183B);

void setup()
{
  pinMode(SERVO_FEEDBACK, INPUT);
  pinMode(HALL_SENSOR, INPUT_PULLUP);
  servo.begin();
  servo.setOscillatorFrequency(27000000);
  servo.setPWMFreq(SERVO_FREQ);
  servo_disengage();

  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);

  Bluefruit.begin();
  Bluefruit.setTxPower(TX_POWER);    // Check bluefruit.h for supported values

  Bluefruit.Security.setMITM(true);
  Bluefruit.Security.setIOCaps(true, false, false); // display = true, yes/no = false, keyboard = false
  Bluefruit.Security.setPairPasskeyCallback(pairing_passkey_callback);

  Bluefruit.Security.setPairCompleteCallback(pairing_complete_callback);
  Bluefruit.Security.setSecuredCallback(connection_secured_callback);
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  bleuart.setPermission(SECMODE_ENC_WITH_LESC_MITM, SECMODE_ENC_WITH_LESC_MITM);
  bleuart.begin();
  bletps.begin();

  startAdv();
}

void startAdv(void)
{
  Bluefruit.setName("Smart Lock");
  Bluefruit.setAppearance(BLE_APPEARANCE_GENERIC_KEYRING);

  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addName();
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addUuid(bluelockId);
  Bluefruit.Advertising.addUuid(UUID16_SVC_TX_POWER);
  Bluefruit.Advertising.addAppearance(BLE_APPEARANCE_GENERIC_KEYRING);

  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

bool locked = false;
bool closed = false;
bool disengaged = false;
unsigned long status_time = 0;
unsigned long ULONG_MAX = 4294967295;

void loop()
{
  if (analogRead(SERVO_FEEDBACK) < SERVO_LOCKED_THRESHOLD != locked) {
    locked = !locked;
    status_time = ULONG_MAX;
  }
  if (!digitalRead(HALL_SENSOR) != closed) {
    closed = !closed;
    status_time = ULONG_MAX;
  }

  unsigned long now_time = millis();
  if (status_time > now_time || now_time - status_time > 1000) {
    status_time = now_time;
    write_status();
  }

  while ( bleuart.available() )
  {
    switch ((uint8_t) bleuart.read()) {
      case 'u':
        servo_unlock();
        break;
      case 'l':
        servo_lock();
        break;
      case 'w':
        delay(500);
        break;
      case 'd':
        servo_disengage();
        break;
      case ' ':
      case '\r':
      case '\n':
        break;
      case 'h':
      case '?':
      default:
        bleuart.write("Send <d> to disengage the servo, <u> to unlock, <l> to lock.");
    }
  }
}

void servo_lock() {
  servo.writeMicroseconds(SERVO_NUM, LOCKED);
  locked = true;
  disengaged = false;
  status_time = ULONG_MAX;
}

void servo_unlock() {
  servo.writeMicroseconds(SERVO_NUM, UNLOCKED);
  locked = false;
  disengaged = false;
  status_time = ULONG_MAX;
}

void servo_disengage() {
  servo.writeMicroseconds(SERVO_NUM, 0);
  disengaged = true;
  status_time = ULONG_MAX;
}

void write_status() {
  String status = "{\"locked\": ";
  status += locked ? "true" : "false";
  status += ", \"closed\": ";
  status += closed ? "true" : "false";
  status += ", \"disengaged\": ";
  status += disengaged ? "true" : "false";
  status += "}";

  bleuart.write(status.c_str());
}

// callback invoked when central connects
void connect_callback(uint16_t conn_handle)
{
  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);
  connection->requestPairing();

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
}

// callback invoked when pairing passkey is generated
// - passkey: 6 keys (without null terminator) for displaying
// - match_request: true when authentication method is Numberic Comparison.
//                  Then this callback's return value is used to accept (true) or
//                  reject (false) the pairing process. Otherwise, return value has no effect
bool pairing_passkey_callback(uint16_t conn_handle, uint8_t const passkey[6], bool match_request)
{
  Serial.println("Pairing Passkey");
  Serial.printf("    %.3s %.3s\n", passkey, passkey+3);

  return true;
}

void pairing_complete_callback(uint16_t conn_handle, uint8_t auth_status)
{
  if (auth_status != BLE_GAP_SEC_STATUS_SUCCESS)
  {
    Serial.println("Secure pairing failed.");
    sd_ble_gap_disconnect(conn_handle, BLE_HCI_AUTHENTICATION_FAILURE);
  }
}

void connection_secured_callback(uint16_t conn_handle)
{
  Serial.println("Connection secured.");
}

/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;

  Serial.println();
  Serial.print("Disconnected, reason = 0x"); Serial.println(reason, HEX);
}
