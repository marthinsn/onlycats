import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation; // Lokasi yang ditunjuk kursor tengah
  LatLng? _currentUserLocation; // Lokasi asli GPS user (Titik Biru)
  String _address = "Mencari lokasi...";
  final MapController _mapController = MapController();
  Timer? _debounce;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? LatLng(-6.200000, 106.816666);
    _getAddress(_selectedLocation!);
    _initLocationTracking();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positionStream?.cancel(); // Berhenti melacak saat keluar layar
    super.dispose();
  }

  // Inisialisasi pelacakan real-time
  Future<void> _initLocationTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _address =
              'Layanan lokasi belum aktif. Aktifkan GPS, lalu tekan tombol lokasi.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          _address =
              'Izin lokasi ditolak. Izinkan akses lokasi untuk memakai posisi saat ini.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _address =
              'Izin lokasi ditolak permanen. Buka Settings untuk mengaktifkan lokasi OnlyCats.';
        });
        return;
      }

      // Ambil lokasi awal
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 12),
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
        if (widget.initialLocation == null) {
          _selectedLocation = _currentUserLocation;
          _mapController.move(_currentUserLocation!, 17);
          _getAddress(_currentUserLocation!);
        }
      });

      // Mulai dengerin perubahan posisi secara real-time (Blue Dot bergerak)
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 2, // Update setiap bergerak 2 meter
            ),
          ).listen((Position position) {
            if (!mounted) return;

            setState(() {
              _currentUserLocation = LatLng(
                position.latitude,
                position.longitude,
              );
            });
          });
    } on TimeoutException {
      if (!mounted) return;

      setState(() {
        _address =
            'GPS belum mendapatkan lokasi. Coba pindah ke area terbuka atau tekan tombol lokasi lagi.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _address = 'Gagal mengambil lokasi: $e';
      });
    }
  }

  Future<void> _centerOnUser() async {
    if (_currentUserLocation != null) {
      _mapController.move(_currentUserLocation!, 17);
      setState(() {
        _selectedLocation = _currentUserLocation;
      });
      _getAddress(_currentUserLocation!);
      return;
    }

    setState(() {
      _address = 'Mengambil lokasi saat ini...';
    });
    await _initLocationTracking();
  }

  Future<void> _getAddress(LatLng location) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&zoom=18&addressdetails=1',
        );

        final response = await http
            .get(url, headers: {'User-Agent': 'OnlyCatsApp/1.0'})
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (!mounted) return;

          setState(() {
            _address = data['display_name'] ?? "Alamat tidak ditemukan";
          });
        } else {
          if (!mounted) return;

          setState(() {
            _address = "Alamat tidak ditemukan.";
          });
        }
      } catch (e) {
        if (mounted) setState(() => _address = "Gagal mendapatkan alamat.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geser Peta ke Lokasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? LatLng(-6.200000, 106.816666),
              initialZoom: 17,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation = position.center;
                  });
                }
              },
              onMapEvent: (event) {
                if (event is MapEventMoveEnd ||
                    event is MapEventFlingAnimationEnd) {
                  if (_selectedLocation != null) {
                    _getAddress(_selectedLocation!);
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.onlycats',
              ),
              // Blue Dot (Titik Lokasi User Asli)
              if (_currentUserLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentUserLocation!,
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Panel Koordinat Real-Time (Overlay)
          if (_currentUserLocation != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GPS REAL-TIME:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat: ${_currentUserLocation!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Lng: ${_currentUserLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Center Marker (Target Rescue)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on,
                color: AppColors.orange,
                size: 45,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectedLocation == null
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'location': _selectedLocation,
                                'address': _address,
                              });
                            },
                      child: const Text(
                        'Konfirmasi Lokasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
