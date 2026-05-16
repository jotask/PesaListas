import 'package:flutter/widgets.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/core/vote_summary_fields.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';

class AppItemVoteSummary {
  const AppItemVoteSummary(this.item);

  final Map<String, dynamic> item;

  int get voteCount {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.voteCount]) ?? 0;
  }

  int get totalPoints {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.totalPoints]) ??
        0;
  }

  int? get myPoints {
    return AppValueParsing.intOrNull(item[AppVoteSummaryFields.myPoints]);
  }

  double get averagePoints {
    final value = item[AppVoteSummaryFields.averagePoints];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool get hasVotes {
    return voteCount > 0;
  }

  String get averageText {
    if (!hasVotes) return '—';

    return averagePoints.toStringAsFixed(1);
  }

  String voteCountText(BuildContext context) {
    if (voteCount == 0) return context.l10n.noVotesYet;
    if (voteCount == 1) return context.l10n.voteCountOne;

    return context.l10n.voteCountMany(voteCount);
  }
}
