package com.example.refine.receivers

import android.app.admin.DeviceAdminReceiver

// Only requests the FORCE_LOCK policy so reFine can lock the screen for the
// double-tap-to-sleep gesture. No other device admin capabilities are used.
class RefineDeviceAdminReceiver : DeviceAdminReceiver()
