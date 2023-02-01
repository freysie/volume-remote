@import CoreGraphics;

bool DisplayServicesCanChangeBrightness(CGDirectDisplayID display);
CGError DisplayServicesGetBrightness(CGDirectDisplayID display, float *brightness);
CGError DisplayServicesSetBrightness(CGDirectDisplayID display, float brightness);
CGError DisplayServicesRegisterForBrightnessChangeNotifications(CGDirectDisplayID display, const void *observer, CFNotificationCallback callback);

//double CoreDisplay_Display_GetUserBrightess(CGDirectDisplayID display);
//void CoreDisplay_Display_SetUserBrightess(CGDirectDisplayID display, double brightness);
