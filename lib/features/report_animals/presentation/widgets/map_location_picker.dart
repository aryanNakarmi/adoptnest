import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:adoptnest/features/report_animals/domain/entities/location_value.dart';

// Default center: Kathmandu
const _kDefaultCenter = LatLng(27.7172, 85.3240);

Future<String> _reverseGeocode(double lat, double lng) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'lat': lat,
        'lon': lng,
        'format': 'json',
        'zoom': 18,
        'addressdetails': 1,
      },
      options: Options(headers: {
        'Accept-Language': 'en',
        'User-Agent': 'AdoptNest/1.0',
      }),
    );
    final data = response.data as Map<String, dynamic>;
    if (data['error'] != null) return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    final a = data['address'] as Map<String, dynamic>? ?? {};
    final parts = <String>[
      a['road'] ?? a['pedestrian'] ?? a['footway'] ?? a['path'] ?? '',
      a['suburb'] ?? a['neighbourhood'] ?? a['quarter'] ?? '',
      a['city'] ?? a['town'] ?? a['village'] ?? a['municipality'] ?? '',
    ].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : (data['display_name'] as String? ?? '$lat, $lng');
  } catch (_) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }
}

class MapLocationPicker extends StatefulWidget {
  final LocationValue? value;
  final ValueChanged<LocationValue> onChange;

  const MapLocationPicker({
    super.key,
    this.value,
    required this.onChange,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late final MapController _mapController;
  Timer? _debounce;

  LatLng _center = _kDefaultCenter;
  String _address = '';
  bool _loading = false;
  bool _dragging = false;
  bool _firstMove = false;
  bool _gettingGPS = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.value != null) {
      _center = LatLng(widget.value!.lat, widget.value!.lng);
      _address = widget.value!.address;
      _firstMove = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocation(_center.latitude, _center.longitude);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _debouncedUpdate(double lat, double lng) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () => _updateLocation(lat, lng));
  }

  Future<void> _updateLocation(double lat, double lng) async {
    setState(() => _loading = true);
    final addr = await _reverseGeocode(lat, lng);
    if (!mounted) return;
    setState(() {
      _address = addr;
      _loading = false;
    });
    widget.onChange(LocationValue(address: addr, lat: lat, lng: lng));
  }

  Future<void> _getGPSLocation() async {
    setState(() => _gettingGPS = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Enable location permission in settings');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      _mapController.move(latLng, 18);
      setState(() {
        _center = latLng;
        _firstMove = true;
      });
      _updateLocation(pos.latitude, pos.longitude);
    } catch (e) {
      _showError('Failed to get location');
    } finally {
      if (mounted) setState(() => _gettingGPS = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                // ── Map ──
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 16,
                    onMapEvent: (event) {
                      if (event is MapEventMoveStart) {
                        setState(() => _dragging = true);
                      } else if (event is MapEventMoveEnd) {
                        final c = _mapController.camera.center;
                        setState(() {
                          _dragging = false;
                          _firstMove = true;
                          _center = c;
                        });
                        _debouncedUpdate(c.latitude, c.longitude);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.adoptnest.app',
                    ),
                  ],
                ),

                // ── Fixed center pin ──
                IgnorePointer(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -28),
                      child: AnimatedScale(
                        scale: _dragging ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                                ],
                              ),
                              child: const Center(
                                child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
                              ),
                            ),
                            Container(width: 2, height: 16, color: Colors.red),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(_dragging ? 0.2 : 0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── My Location button ──
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _gettingGPS ? null : _getGPSLocation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_gettingGPS)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.red),
                                ),
                              )
                            else
                              const Icon(Icons.my_location, size: 14, color: Colors.red),
                            const SizedBox(width: 5),
                            Text(
                              _gettingGPS ? 'Locating...' : 'My Location',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Status pill ──
                if (_dragging || _loading)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _dragging
                              ? [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Drag to position...', style: TextStyle(fontSize: 12)),
                                ]
                              : [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Finding address...', style: TextStyle(fontSize: 12)),
                                ],
                        ),
                      ),
                    ),
                  ),

                // ── First-time hint ──
                if (!_firstMove && !_loading)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Drag map to position the pin',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Address bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: Colors.red, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SELECTED LOCATION',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dragging
                            ? 'Positioning...'
                            : _loading
                                ? 'Getting address...'
                                : _address.isNotEmpty
                                    ? _address
                                    : 'Move the map to select a location',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Footer hint ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.grey.shade50,
            child: const Text(
              'Drag the map to place the pin exactly where you saw the animal',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
