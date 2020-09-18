#include "extend.h"
#include <modbus/modbus-version.h>
#include <modbus/modbus.h>
#include <sys/types.h>

const char *CModbus_Version() 
{
  return LIBMODBUS_VERSION_STRING; 
}


void modbus_set_response_timeout_seconds(modbus_t *ctx, double seconds) 
{
    struct timeval tval;
    tval.tv_sec = static_cast<int>(seconds);
    tval.tv_usec = static_cast<int>((seconds - tval.tv_sec) * 1000000);
    modbus_set_response_timeout(ctx, &tval);
}


double modbus_get_response_timeout_seconds(modbus_t *ctx) 
{
    struct timeval tval;
    modbus_get_response_timeout(ctx, &tval);

    return tval.tv_sec + tval.tv_usec * 0.000001;
}


void modbus_set_byte_timeout_seconds(modbus_t *ctx, double seconds) 
{
    struct timeval tval;
    tval.tv_sec = static_cast<int>(seconds);
    tval.tv_usec = static_cast<int>((seconds - tval.tv_sec) * 1000000);
    modbus_set_byte_timeout(ctx, &tval);
}


double modbus_get_byte_timeout_seconds(modbus_t *ctx) 
{
    struct timeval tval;
    modbus_get_byte_timeout(ctx, &tval);

    return tval.tv_sec + tval.tv_usec * 0.000001;
}


