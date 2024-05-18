#ifndef BLETPS_H_
#define BLETPS_H_

#include "bluefruit_common.h"

#include "BLECharacteristic.h"
#include "BLEService.h"

class BLETps : public BLEService
{
  protected:
    BLECharacteristic _txPower;
    int8_t _level;

  public:
    BLETps(int8_t level);

    virtual err_t begin(void);
};



#endif /* BLETPS_H_ */