import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/fields/vote_summary_fields.dart';
import 'package:pesalistas/core/item_vote_summary.dart';

void main() {
  group('AppItemVoteSummary', () {
    test('uses zero defaults when summary fields are missing', () {
      const summary = AppItemVoteSummary({});

      expect(summary.voteCount, 0);
      expect(summary.totalPoints, 0);
      expect(summary.myPoints, null);
      expect(summary.averagePoints, 0.0);
      expect(summary.hasVotes, false);
      expect(summary.averageText, '—');
    });

    test('parses numeric and string summary values', () {
      const summary = AppItemVoteSummary({
        AppVoteSummaryFields.voteCount: '3',
        AppVoteSummaryFields.totalPoints: '24',
        AppVoteSummaryFields.myPoints: '8',
        AppVoteSummaryFields.averagePoints: '8.0',
      });

      expect(summary.voteCount, 3);
      expect(summary.totalPoints, 24);
      expect(summary.myPoints, 8);
      expect(summary.averagePoints, 8.0);
      expect(summary.hasVotes, true);
      expect(summary.averageText, '8.0');
    });

    test('formats average with one decimal place', () {
      const summary = AppItemVoteSummary({
        AppVoteSummaryFields.voteCount: 2,
        AppVoteSummaryFields.averagePoints: 7.25,
      });

      expect(summary.averageText, '7.3');
    });
  });
}
