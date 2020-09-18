#ifdef __APPLE__
#include "/usr/local/include/modbus/modbus.h"
#else
#include <modbus/modbus.h>
#endif
#undef LIBMODBUS_VERSION
