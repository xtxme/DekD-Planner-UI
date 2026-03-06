import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:my_first_app/features/home/data/models/canvas_assignment.dart';
import 'package:my_first_app/features/home/data/remote/canvas_assignment_remote_data_source.dart';

/// Retries the given async function with exponential backoff on specific errors.
///
/// [maxAttempts]: Maximum number of retry attempts (including initial attempt)
/// [initialDelay]: Delay before first retry
/// [maxDelay]: Maximum delay between retries
/// [multiplier]: Backoff multiplier (default: 2x)
/// [shouldRetry]: Function to determine if an error should trigger a retry
Future<T> retryWithExponentialBackoff<T>({
  required Future<T> Function() operation,
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration maxDelay = const Duration(seconds: 5),
  double multiplier = 2.0,
  bool Function(Object error)? shouldRetry,
}) async {
  assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

  int attempt = 0;
  Duration delay = initialDelay;

  while (true) {
    attempt++;

    try {
      debugPrint('RETRY_DEBUG: Attempt $attempt/$maxAttempts');
      return await operation();
    } catch (error) {
      final shouldRetryThis = shouldRetry?.call(error) ?? false;

      if (attempt >= maxAttempts || !shouldRetryThis) {
        debugPrint('RETRY_DEBUG: Giving up after $attempt attempts');
        debugPrint('RETRY_DEBUG: Final error: $error');
        rethrow;
      }

      debugPrint(
        'RETRY_DEBUG: Error on attempt $attempt, retrying in ${delay.inMilliseconds}ms...',
      );
      debugPrint('RETRY_DEBUG: Error: $error');

      await Future.delayed(delay);

      // Calculate next delay with exponential backoff
      delay = Duration(
        milliseconds: (delay.inMilliseconds * multiplier)
            .clamp(initialDelay.inMilliseconds, maxDelay.inMilliseconds)
            .toInt(),
      );
    }
  }
}

/// Extension to add retry capability to CanvasAssignmentRemoteDataSource
extension CanvasAssignmentRemoteDataSourceRetry
    on CanvasAssignmentRemoteDataSource {
  /// Fetches assignments with automatic retry on auth failures
  Future<CanvasAssignmentsResponse> fetchAssignmentsWithUserRetry({
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) {
    return retryWithExponentialBackoff(
      operation: fetchAssignmentsWithUser,
      maxAttempts: maxAttempts,
      initialDelay: initialDelay,
      shouldRetry: (error) {
        // Retry on auth-related exceptions
        if (error is CanvasSessionExpiredException) {
          debugPrint('RETRY_DEBUG: CanvasSessionExpiredException - will retry');
          return true;
        }
        if (error.toString().toLowerCase().contains('invalid jwt')) {
          debugPrint('RETRY_DEBUG: Invalid JWT error - will retry');
          return true;
        }
        if (error.toString().toLowerCase().contains('unauthorized')) {
          debugPrint('RETRY_DEBUG: Unauthorized error - will retry');
          return true;
        }

        // Don't retry on other errors
        return false;
      },
    );
  }
}
