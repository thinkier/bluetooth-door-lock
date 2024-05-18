#include "bluefruit.h"
#include "BLETps.h"

BLETps::BLETps(int8_t level) :
  BLEService(UUID16_SVC_TX_POWER), _txPower(UUID16_CHR_TX_POWER_LEVEL) {
  _level = level;
}

err_t BLETps::begin(void)
{
  // Invoke base class begin()
  VERIFY_STATUS( BLEService::begin() );

  _txPower.setProperties(CHR_PROPS_READ);
  _txPower.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  _txPower.setFixedLen(1);
  VERIFY_STATUS( _txPower.begin() );

  _txPower.write8(static_cast<uint8_t>(_level));

  return ERROR_NONE;
}
