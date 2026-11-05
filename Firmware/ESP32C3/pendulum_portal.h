#pragma once
// Step Pendulum: makes the phone's "Sign in to network" pop-up open the
// pendulum control page instead of the stock ESPHome Wi-Fi setup page.
//
// While the fallback access point is up, the operating-system connectivity
// checks (generate_204, hotspot-detect.html, ...) are answered with a
// redirect to the web_server page at http://192.168.4.1/.
// Every other unknown URL still gets the ESPHome Wi-Fi setup page, so home
// Wi-Fi credentials can be changed at e.g. http://192.168.4.1/wifi

#include "esphome/core/defines.h"
#include "esphome/components/web_server_base/web_server_base.h"
#include "esphome/components/captive_portal/captive_portal.h"
#include <cstring>

namespace pendulum_portal {

static const char *const PORTAL_URL = "http://192.168.4.1/";

static const char *const PROBE_URLS[] = {
    "/generate_204", "/gen_204",                                // Android, Chrome
    "/hotspot-detect.html", "/library/test/success.html",       // iOS, macOS
    "/ncsi.txt", "/connecttest.txt", "/redirect",               // Windows
    "/canonical.html", "/success.txt",                          // Firefox
    "/check_network_status.txt", "/mobile/status.php",          // misc Android OEMs
};

class ProbeRedirect : public AsyncWebHandler {
 public:
  bool canHandle(AsyncWebServerRequest *request) const override {
    auto *cp = esphome::captive_portal::global_captive_portal;
    if (cp == nullptr || !cp->is_active() || request->method() != HTTP_GET)
      return false;
#ifdef USE_ESP32
    char buf[AsyncWebServerRequest::URL_BUF_SIZE];
    auto url = request->url_to(buf);
    const char *u = url.c_str();
#else
    const auto &s = request->url();
    const char *u = s.c_str();
#endif
    for (const char *p : PROBE_URLS)
      if (std::strcmp(u, p) == 0)
        return true;
    return false;
  }

  void handleRequest(AsyncWebServerRequest *request) override { request->redirect(PORTAL_URL); }
};

inline void install() {
  static ProbeRedirect handler;
  esphome::web_server_base::global_web_server_base->add_handler_without_auth(&handler);
}

}  // namespace pendulum_portal
