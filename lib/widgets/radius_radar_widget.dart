import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RadarPin {
  final String id;
  final String label;
  final String sublabel;
  final double lat;
  final double lng;
  final double distanceKm;
  final String? statusText;

  const RadarPin({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.statusText,
  });
}

class RadiusRadarWidget extends StatefulWidget {
  final String originName;
  final double originLat;
  final double originLng;
  final double radiusKm;
  final List<RadarPin> pins;
  final ValueChanged<RadarPin>? onSelectPin;

  const RadiusRadarWidget({
    super.key,
    required this.originName,
    required this.originLat,
    required this.originLng,
    required this.radiusKm,
    required this.pins,
    this.onSelectPin,
  });

  @override
  State<RadiusRadarWidget> createState() => _RadiusRadarWidgetState();
}

class _RadiusRadarWidgetState extends State<RadiusRadarWidget> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final activePin = widget.pins.where((p) => p.id == _selectedId).firstOrNull ??
        widget.pins.firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '10–15 km Spatial Proximity Radar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Origin: ${widget.originName}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${widget.radiusKm.toInt()} km · ${widget.pins.length} pins',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 1.25,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final cx = w / 2;
                  final cy = h / 2;
                  final maxR = math.min(cx, cy) * 0.86;
                  final maxScaleKm = math.max(15.0, widget.radiusKm);
                  final cosLat = math.cos(widget.originLat * math.pi / 180.0);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(w, h),
                          painter: _RadarGridPainter(
                            radiusKm: widget.radiusKm,
                            maxScaleKm: maxScaleKm,
                          ),
                        ),
                        const Positioned(
                          top: 10,
                          left: 12,
                          child: Text(
                            '15 km outer · 10 km inner',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Positioned(
                          left: cx - 7,
                          top: cy - 7,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                        ...widget.pins.map((pin) {
                          final dyKm = (pin.lat - widget.originLat) * 111.32;
                          final dxKm = (pin.lng - widget.originLng) *
                              111.32 *
                              (cosLat == 0 ? 1 : cosLat);
                          final dist = math.min(
                            maxScaleKm * 0.92,
                            math.sqrt(dxKm * dxKm + dyKm * dyKm),
                          );
                          final angle = math.atan2(dyKm, dxKm);
                          final rPx = (dist / maxScaleKm) * maxR;
                          final px = cx + math.cos(angle) * rPx;
                          final py = cy - math.sin(angle) * rPx;
                          final isSelected = activePin?.id == pin.id;

                          return Positioned(
                            left: px - 16,
                            top: py - 16,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedId = pin.id);
                                widget.onSelectPin?.call(pin);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.teal
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.teal,
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.teal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (activePin != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar, color: AppColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activePin.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            activePin.sublabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${activePin.distanceKm} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final double radiusKm;
  final double maxScaleKm;

  _RadarGridPainter({required this.radiusKm, required this.maxScaleKm});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = math.min(cx, cy) * 0.86;

    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint);
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(cx, cy), maxR, ringPaint);
    canvas.drawCircle(Offset(cx, cy), (10.0 / maxScaleKm) * maxR, ringPaint);

    final activeR = (math.min(maxScaleKm, radiusKm) / maxScaleKm) * maxR;
    final fillPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), activeR, fillPaint);
    canvas.drawCircle(Offset(cx, cy), activeR, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) =>
      oldDelegate.radiusKm != radiusKm;
}
