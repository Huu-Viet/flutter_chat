class WaveformUtils {
  static List<double> normalize(
    List<double> waveform, {
    List<double> fallback = const <double>[0.2, 0.4, 0.3, 0.5, 0.7, 0.35, 0.6],
    int maxBars = 35,
  }) {
    final source = waveform.isNotEmpty ? waveform : fallback;

    // Scale properties based on input volume
    double maxSource = 0.01; // Avoid divide by zero
    for (var value in source) {
      if (value.abs() > maxSource) {
        maxSource = value.abs();
      }
    }

    final dataList = source.map((e) => (e.abs() / maxSource)).toList();

    // Resample to exactly maxBars (upsample or downsample) so it stretches evenly
    final result = <double>[];
    final step = dataList.length / maxBars;
    for (var i = 0; i < maxBars; i++) {
      int start = (i * step).floor();
      int end = ((i + 1) * step).floor();
      if (end > dataList.length) end = dataList.length;

      if (start == end) {
        result.add(dataList[start.clamp(0, dataList.length - 1)]);
      } else {
        double sum = 0;
        for (int j = start; j < end; j++) {
          sum += dataList[j];
        }
        result.add(sum / (end - start));
      }
    }

    // Apply a moving average filter to smooth the transitions between bars
    final smoothed = <double>[];
    for (int i = 0; i < result.length; i++) {
      double prev = i > 0 ? result[i - 1] : result[i];
      double next = i < result.length - 1 ? result[i + 1] : result[i];
      // Weighted average: 1/4 from prev, 1/2 from current, 1/4 from next
      smoothed.add((prev + result[i] * 2 + next) / 4);
    }

    return smoothed;
  }

  static double barHeight(double amplitude) {
    // Scale amplitude relative. We already normalized between 0.0 -> 1.0!
    // Minimum 4, Maximum 24
    return 4.0 + (amplitude.clamp(0.0, 1.0) * 20.0);
  }
}
