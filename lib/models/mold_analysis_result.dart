class MoldAnalysisResult {
  final String moldType;
  final String confidence;
  final String description;
  final String overviewText;
  final String habitatText;
  final Map<String, dynamic> detectionStats;
  final List<Map<String, String>> healthRisks;
  final List<String> preventionMethods;

  MoldAnalysisResult({
    required this.moldType,
    required this.confidence,
    required this.description,
    required this.overviewText,
    required this.habitatText,
    required this.detectionStats,
    required this.healthRisks,
    required this.preventionMethods,
  });

  factory MoldAnalysisResult.fromJson(Map<String, dynamic> json) {
    final primaryIssue = json['primary_issue'] ?? 'Unknown';
    final severity = json['severity'] ?? 'Unknown';
    final observedFeatures = json['observed_features'] as List? ?? [];

    final possibleSpecies =
        (json['possible_species'] ?? json['possibleSpecies'])?.toString();
    final scientific =
        (json['scientific_name'] ?? json['scientificName'])?.toString();

    String moldType = 'Mold';

    if (possibleSpecies != null &&
        possibleSpecies.isNotEmpty &&
        possibleSpecies.toLowerCase() != 'unknown') {
      moldType = possibleSpecies.split('(')[0].trim();
    } else if (scientific != null &&
        scientific.isNotEmpty &&
        scientific.toLowerCase() != 'unknown') {
      moldType = scientific.split('-')[0].trim(); 
    } else if (observedFeatures.isNotEmpty) {
      final first = observedFeatures.first;
      if (first is Map) {
        final type = first['type']?.toString() ?? '';
        final colors =
            (first['color'] is List && (first['color'] as List).isNotEmpty)
                ? (first['color'] as List).map((c) => c.toString()).join('-')
                : null;
        if (colors != null && colors.isNotEmpty) {
          moldType = '${colors.capitalizeFirst()} mold';
        } else if (type.isNotEmpty) {
          moldType = type;
        }
      }
    }

    String featureDescription;

    if (observedFeatures.isNotEmpty && observedFeatures.first is Map) {
      final first = observedFeatures.first as Map;
      final desc = first['description']?.toString() ?? '';
      final colors =
          (first['color'] is List && (first['color'] as List).isNotEmpty)
              ? (first['color'] as List).map((c) => c.toString()).join(', ')
              : '';

      if (desc.isNotEmpty) {
        featureDescription = desc;
        if (colors.isNotEmpty) {
          featureDescription += ' (Colors: $colors)';
        }
      } else if (possibleSpecies != null && possibleSpecies.isNotEmpty) {
        featureDescription = possibleSpecies;
      } else {
        featureDescription = primaryIssue.toString();
      }
    } else if (possibleSpecies != null && possibleSpecies.isNotEmpty) {
      featureDescription = possibleSpecies;
    } else {
      featureDescription = primaryIssue.toString();
    }

    int? tryExtractPercent(dynamic v) {
      if (v == null) return null;
      if (v is num) {
        final d = v.toDouble();
        if (d > 0 && d <= 1) {
          return (d * 100).round().clamp(0, 100);
        }
        return d.round().clamp(0, 100);
      }
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      final m = RegExp(r'(\d{1,3}(?:\.\d+)?)').firstMatch(s);
      if (m != null) {
        final d = double.tryParse(m.group(1)!);
        if (d != null) {
          if (d > 0 && d <= 1) return (d * 100).round().clamp(0, 100);
          return d.round().clamp(0, 100);
        }
      }
      return null;
    }

    int? confidencePercent =
        tryExtractPercent(json['confidence_percent']) ??
        tryExtractPercent(json['confidence']);

    if (confidencePercent == null) {
      switch (severity.toString().toLowerCase()) {
        case 'high':
          confidencePercent = 85;
          break;
        case 'medium':
          confidencePercent = 70;
          break;
        case 'low':
          confidencePercent = 55;
          break;
        default:
          confidencePercent = null;
      }
    }

    final confidenceStr =
        confidencePercent != null
            ? '${confidencePercent.clamp(0, 100)}%'
            : (json['confidence']?.toString() ?? 'Unknown');

    final rawCommon =
        json['commonInHomes'] ??
        json['common_in_homes'] ??
        json['common_in_home'] ??
        json['commonHomes'];

    String commonStr = rawCommon?.toString() ?? '63%';
    final numMatch = RegExp(r'(\d{1,3})').firstMatch(commonStr);
    if (numMatch != null) {
      final n = int.parse(numMatch.group(1)!).clamp(0, 100);
      commonStr = '$n%';
    } else {
      if (RegExp(r'^\d+$').hasMatch(commonStr)) commonStr = '${commonStr}%';
      if (commonStr.toLowerCase().contains('unknown'))
        commonStr = '63%'; 
    }

    final stats = {
      'severity': severity,
      'accuracy': confidenceStr,
      'accuracyPercent': confidencePercent,
      'detectionConfidence': confidenceStr,
      'commonInHomes': commonStr,
    };

    List<Map<String, String>> risks = [];
    final rawRisks = json['health_implications'];
    if (rawRisks is List && rawRisks.isNotEmpty) {
      risks =
          rawRisks.map((item) {
            if (item is Map) {
              return {
                'title': item['title']?.toString() ?? 'Unknown',
                'details': item['details']?.toString() ?? 'Unknown',
              };
            }
            return {'title': item.toString(), 'details': ''};
          }).toList();
    }

    List<String> prevention = [];
    if (json['recommended_actions'] is List) {
      prevention = List<String>.from(
        (json['recommended_actions'] as List)
            .map((a) => a.toString())
            .where((a) => a.isNotEmpty && a.toLowerCase() != 'unknown'),
      );
    } else if (json['recommendedActions'] is List) {
      prevention = List<String>.from(
        (json['recommendedActions'] as List)
            .map((a) => a.toString())
            .where((a) => a.isNotEmpty && a.toLowerCase() != 'unknown'),
      );
    }

    final habitat =
        (json['habitat_text'] ?? json['habitatText'] ?? '').toString().trim();
    final overview =
        (json['underlying_cause_indication'] ??
                json['underlyingCauseIndication'] ??
                '')
            .toString()
            .trim();

    final computedHabitat = _buildHabitatText(observedFeatures, json);

    return MoldAnalysisResult(
      moldType: moldType,
      confidence: confidenceStr,
      description: featureDescription,
      overviewText:
          overview.isNotEmpty
              ? overview
              : 'Likely moisture source such as a leak, condensation, or poor ventilation.',
      habitatText: habitat.isNotEmpty ? habitat : computedHabitat,
      detectionStats: stats,
      healthRisks: risks,
      preventionMethods: prevention,
    );
  }

  static String _buildHabitatText(
    List observedFeatures,
    Map<String, dynamic> json,
  ) {
    final buf = StringBuffer();

    for (var feature in observedFeatures) {
      if (feature is Map) {
        final type = (feature['type'] ?? feature['name'] ?? '').toString();
        final sci =
            (feature['scientific_name'] ?? feature['scientificName'] ?? '')
                .toString();
        final desc =
            (feature['description'] ?? feature['desc'] ?? '').toString();
        final colors =
            (feature['color'] is List && feature['color'].isNotEmpty)
                ? (feature['color'] as List).map((c) => c.toString()).join(', ')
                : '';

        final lineParts = <String>[];
        if (type.isNotEmpty) lineParts.add(type);
        if (sci.isNotEmpty) lineParts.add('($sci)');
        if (desc.isNotEmpty) lineParts.add(': $desc');
        if (colors.isNotEmpty) lineParts.add('[colors: $colors]');

        if (lineParts.isNotEmpty) {
          buf.writeln(lineParts.join(' '));
        }
      }
    }

    if (json['underlying_cause_indication'] != null) {
      buf.writeln('\nCause: ${json['underlying_cause_indication']}');
    }

    return buf.toString().isNotEmpty
        ? buf.toString()
        : 'Mold thrives in damp, dark environments with poor ventilation.';
  }
}

extension StringHelpers on String {
  String capitalizeFirst() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
