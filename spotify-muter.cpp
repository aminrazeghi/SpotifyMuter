#include <iostream>
#include <string>
#include <algorithm>
#include <gio/gio.h>
#include <unistd.h>

// Helper to check for "advertisement"
bool is_ad(const std::string& title) {
    std::string lower = title;
    std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    return lower.find("advertisement") != std::string::npos;
}

// Function to set volume for a specific player name
void set_player_volume(GDBusConnection* conn, const char* name, double volume) {
    GError* error = nullptr;

    // We need to wrap the double into a Variant(v), 
    // because "Volume" is a property of type double, 
    // and the "Set" method expects (string, string, variant)
    GVariant* value = g_variant_new_double(volume);
    GVariant* params = g_variant_new("(ssv)", 
                                    "org.mpris.MediaPlayer2.Player", 
                                    "Volume", 
                                    value);

    GVariant* res = g_dbus_connection_call_sync(
        conn,
        name,
        "/org/mpris/MediaPlayer2",
        "org.freedesktop.DBus.Properties",
        "Set",
        params,
        nullptr, // No expected return type for Set
        G_DBUS_CALL_FLAGS_NONE,
        -1,
        nullptr,
        &error
    );

    if (error) {
        std::cerr << "Error setting volume for " << name << ": " << error->message << std::endl;
        g_error_free(error);
    } else {
        if (res) g_variant_unref(res);
    }
}

void monitor_and_mute(GDBusConnection* connection) {
    GError* error = nullptr;
    GVariant* result = g_dbus_connection_call_sync(
        connection, "org.freedesktop.DBus", "/org/freedesktop/DBus",
        "org.freedesktop.DBus", "ListNames", nullptr, G_VARIANT_TYPE("(as)"),
        G_DBUS_CALL_FLAGS_NONE, -1, nullptr, &error);

    if (!result) return;

    GVariantIter* iter;
    g_variant_get(result, "(as)", &iter);
    char* name;

    while (g_variant_iter_next(iter, "s", &name)) {
        if (g_str_has_prefix(name, "org.mpris.MediaPlayer2.")) {
            // Get Metadata
            GVariant* v = g_dbus_connection_call_sync(
                connection, name, "/org/mpris/MediaPlayer2",
                "org.freedesktop.DBus.Properties", "Get",
                g_variant_new("(ss)", "org.mpris.MediaPlayer2.Player", "Metadata"),
                G_VARIANT_TYPE("(v)"), G_DBUS_CALL_FLAGS_NONE, -1, nullptr, nullptr);

            if (v) {
                GVariant* dict;
                g_variant_get(v, "(v)", &dict);
                const gchar* title = nullptr;
                
                if (g_variant_lookup(dict, "xesam:title", "s", &title)) {
                    if (is_ad(title)) {
                        std::cout << "[!] Ad Detected: " << title << " -> MUTING" << std::endl;
                        set_player_volume(connection, name, 0.0);
                    } else {
                        // Check if it's currently muted (0.0) and unmute it
                        GVariant* vol_v = g_dbus_connection_call_sync(
                            connection, name, "/org/mpris/MediaPlayer2",
                            "org.freedesktop.DBus.Properties", "Get",
                            g_variant_new("(ss)", "org.mpris.MediaPlayer2.Player", "Volume"),
                            G_VARIANT_TYPE("(v)"), G_DBUS_CALL_FLAGS_NONE, -1, nullptr, nullptr);
                        
                        if (vol_v) {
                            GVariant* inner_v;
                            g_variant_get(vol_v, "(v)", &inner_v);
                            if (g_variant_get_double(inner_v) == 0.0) {
                                std::cout << "[+] Content Resumed: " << title << " -> UNMUTING" << std::endl;
                                set_player_volume(connection, name, 1.0);
                            }
                            g_variant_unref(inner_v);
                            g_variant_unref(vol_v);
                        }
                    }
                }
                g_variant_unref(dict);
                g_variant_unref(v);
            }
        }
        g_free(name);
    }
    g_variant_iter_free(iter);
    g_variant_unref(result);
}

int main() {
    GDBusConnection* connection = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, nullptr);
    if (!connection) return 1;

    std::cout << "Mute-on-Ad Service started..." << std::endl;

    while (true) {
        monitor_and_mute(connection);
        usleep(1000000); // Check every 1 second
    }

    g_object_unref(connection);
    return 0;
}
