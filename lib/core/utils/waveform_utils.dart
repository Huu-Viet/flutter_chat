class WaveformUtils {
  static List<double> normalize(
    List<double> waveform, {
    List<double> fallback = const <double>[0.2, 0.4, 0.3, 0.5, 0.7, 0.35, 0.6],
    int maxBars = 35,
  }) {
    if (maxBars <= 0) {
      return const <double>[];
    }

    final source = waveform.isNotEmpty ? waveform : fallback;

    final sanitized = source
        .map((value) {
          if (value.isNaN || value.isInfinite) {
            return 0.0;
          }
          return value.abs();
        })
        .toList(growable: false);

    // Scale properties based on input volume
    double maxSource = 0.01; // Avoid divide by zero
    for (final value in sanitized) {
      if (value > maxSource) {
        maxSource = value;
      }
    }

    final dataList = sanitized
        .map((value) => (value / maxSource).clamp(0.0, 1.0).toDouble())
        .toList(growable: false);

    // Resample to exactly maxBars using linear interpolation to reduce jagged changes.
    final result = List<double>.filled(maxBars, 0.0, growable: false);
    final sourceLength = dataList.length;
    if (sourceLength == 1) {
      return List<double>.filled(maxBars, dataList.first, growable: false);
    }

    for (int i = 0; i < maxBars; i++) {
      final t = maxBars == 1 ? 0.0 : i / (maxBars - 1);
      final position = t * (sourceLength - 1);
      final left = position.floor();
      final right = (left + 1).clamp(0, sourceLength - 1);
      final fraction = position - left;
      final value = (dataList[left] * (1 - fraction)) + (dataList[right] * fraction);
      result[i] = value.clamp(0.0, 1.0).toDouble();
    }

    // Two-pass weighted smoothing makes pitch transitions feel more natural.
    List<double> smoothed = List<double>.from(result, growable: false);
    for (int pass = 0; pass < 2; pass++) {
      final next = List<double>.filled(maxBars, 0.0, growable: false);
      for (int i = 0; i < maxBars; i++) {
        final m2 = smoothed[(i - 2).clamp(0, maxBars - 1)];
        final m1 = smoothed[(i - 1).clamp(0, maxBars - 1)];
        final c = smoothed[i];
        final p1 = smoothed[(i + 1).clamp(0, maxBars - 1)];
        final p2 = smoothed[(i + 2).clamp(0, maxBars - 1)];
        next[i] = ((m2 + (m1 * 4) + (c * 6) + (p1 * 4) + p2) / 16)
            .clamp(0.0, 1.0)
            .toDouble();
      }
      smoothed = next;
    }

    return smoothed;
  }

  static double barHeight(double amplitude) {
    // Scale amplitude relative. We already normalized between 0.0 -> 1.0!
    // Minimum 4, Maximum 24
    return 4.0 + (amplitude.clamp(0.0, 1.0) * 20.0);
  }
}
