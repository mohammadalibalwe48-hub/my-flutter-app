import 'package:flutter/material.dart';

class DeviceSpec {
  final String name;
  final String platform;
  final Size logicalSize;
  final double borderRadius;
  final bool hasDynamicIsland;

  const DeviceSpec({
    required this.name,
    required this.platform,
    required this.logicalSize,
    required this.borderRadius,
    this.hasDynamicIsland = false,
  });
}

const List<DeviceSpec> kEmulatorDevices = [
  DeviceSpec(
    name: 'Pixel 9 Pro',
    platform: 'Android 15',
    logicalSize: Size(412, 915),
    borderRadius: 42,
    hasDynamicIsland: false,
  ),
  DeviceSpec(
    name: 'Galaxy S25',
    platform: 'Android 15',
    logicalSize: Size(384, 854),
    borderRadius: 34,
    hasDynamicIsland: false,
  ),
  DeviceSpec(
    name: 'iPhone 16 Pro',
    platform: 'iOS 18',
    logicalSize: Size(393, 852),
    borderRadius: 48,
    hasDynamicIsland: true,
  ),
];

class MobileEmulatorFrame extends StatefulWidget {
  final Widget Function(ThemeMode themeMode) appBuilder;

  const MobileEmulatorFrame({super.key, required this.appBuilder});

  @override
  State<MobileEmulatorFrame> createState() => _MobileEmulatorFrameState();
}

class _MobileEmulatorFrameState extends State<MobileEmulatorFrame> {
  int _selectedDeviceIndex = 0;
  bool _isLandscape = false;
  bool _enableFrame = true;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final device = kEmulatorDevices[_selectedDeviceIndex];
    final isDark = _themeMode == ThemeMode.dark;
    final screenWidth = _isLandscape
        ? device.logicalSize.height
        : device.logicalSize.width;
    final screenHeight = _isLandscape
        ? device.logicalSize.width
        : device.logicalSize.height;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFF0F172A),
        child: Column(
          children: [
            // Top Emulator Control Bar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF334155), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_android,
                    color: Color(0xFF38BDF8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Flutter Mobile Simulator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Device Selector Pills
                  ...List.generate(kEmulatorDevices.length, (index) {
                    final d = kEmulatorDevices[index];
                    final selected = _selectedDeviceIndex == index && _enableFrame;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedDeviceIndex = index;
                          _enableFrame = true;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0284C7)
                                : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${d.name} (${d.platform})',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // Rotate button
                  _ToolbarButton(
                    icon: Icons.screen_rotation,
                    label: _isLandscape ? 'Landscape' : 'Portrait',
                    onTap: () => setState(() => _isLandscape = !_isLandscape),
                  ),
                  const SizedBox(width: 8),
                  // Theme mode button
                  _ToolbarButton(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    label: isDark ? 'Dark' : 'Light',
                    onTap: () => setState(() {
                      _themeMode =
                          isDark ? ThemeMode.light : ThemeMode.dark;
                    }),
                  ),
                  const SizedBox(width: 8),
                  // Toggle Phone Frame vs Full Window
                  _ToolbarButton(
                    icon: _enableFrame ? Icons.fullscreen : Icons.smartphone,
                    label: _enableFrame ? 'Full Screen' : 'Phone Frame',
                    onTap: () => setState(() => _enableFrame = !_enableFrame),
                  ),
                ],
              ),
            ),

            // Emulator Viewport
            Expanded(
              child: _enableFrame
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Container(
                            width: screenWidth + 24,
                            height: screenHeight + 24,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(
                                device.borderRadius + 8,
                              ),
                              border: Border.all(
                                color: const Color(0xFF475569),
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 36,
                                  offset: Offset(0, 18),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                device.borderRadius,
                              ),
                              child: SizedBox(
                                width: screenWidth,
                                height: screenHeight,
                                child: MediaQuery(
                                  data: MediaQueryData(
                                    size: Size(screenWidth, screenHeight),
                                    padding: const EdgeInsets.only(
                                      top: 36,
                                      bottom: 20,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Actual Flutter App
                                      Positioned.fill(
                                        child: widget.appBuilder(_themeMode),
                                      ),
                                      // Status Bar + Camera Punch-Hole / Dynamic Island
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: IgnorePointer(
                                          child: Container(
                                            height: 34,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 22,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '9:41',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black87,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .signal_cellular_alt,
                                                          size: 14,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          Icons.wifi,
                                                          size: 14,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          Icons.battery_full,
                                                          size: 15,
                                                          color: isDark
                                                              ? Colors.white
                                                              : Colors.black87,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                // Camera Cutout
                                                Container(
                                                  width: device.hasDynamicIsland
                                                      ? 96
                                                      : 16,
                                                  height:
                                                      device.hasDynamicIsland
                                                      ? 24
                                                      : 16,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Bottom Home Gesture Pill
                                      Positioned(
                                        bottom: 6,
                                        left: 0,
                                        right: 0,
                                        child: IgnorePointer(
                                          child: Center(
                                            child: Container(
                                              width: 120,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.white38
                                                    : Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : widget.appBuilder(_themeMode),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCBD5E1), size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
