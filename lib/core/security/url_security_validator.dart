/// Validation result for server URLs
class UrlSecurityValidationResult {
  final bool isValid;
  final String? errorMessage;
  final bool isSecureHttps;

  const UrlSecurityValidationResult({
    required this.isValid,
    this.errorMessage,
    required this.isSecureHttps,
  });

  static const UrlSecurityValidationResult validHttps =
      UrlSecurityValidationResult(isValid: true, isSecureHttps: true);
}

/// Security validator to prevent insecure cleartext communication
/// and malformed endpoint injections.
class UrlSecurityValidator {
  UrlSecurityValidator._();

  static const List<String> localHosts = [
    'localhost',
    '127.0.0.1',
    '10.0.2.2',
  ];

  /// Validates the given [urlString] for security constraints:
  /// 1. Must parse as a valid URI with a host.
  /// 2. Must use HTTP or HTTPS scheme.
  /// 3. If [enforceHttpsForRemote] is true, non-local/public domains MUST use HTTPS.
  static UrlSecurityValidationResult validate(
    String urlString, {
    bool enforceHttpsForRemote = true,
  }) {
    final cleaned = urlString.trim();
    if (cleaned.isEmpty) {
      return const UrlSecurityValidationResult(
        isValid: false,
        errorMessage: 'URL server tidak boleh kosong.',
        isSecureHttps: false,
      );
    }

    final uri = Uri.tryParse(cleaned);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return const UrlSecurityValidationResult(
        isValid: false,
        errorMessage: 'Format URL tidak valid. Sertakan skema (contoh: https://domain.com:8097).',
        isSecureHttps: false,
      );
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') {
      return UrlSecurityValidationResult(
        isValid: false,
        errorMessage: 'Skema "$scheme" tidak didukung. Gunakan https:// atau http://.',
        isSecureHttps: false,
      );
    }

    final isHttps = scheme == 'https';
    final host = uri.host.toLowerCase();
    final isLocal = isLocalHost(host);

    if (enforceHttpsForRemote && !isHttps && !isLocal) {
      return const UrlSecurityValidationResult(
        isValid: false,
        errorMessage:
            'Domain publik wajib menggunakan HTTPS untuk mencegah penyadapan data (MitM).',
        isSecureHttps: false,
      );
    }

    return UrlSecurityValidationResult(
      isValid: true,
      isSecureHttps: isHttps,
    );
  }

  /// Checks if [host] is a loopback, emulator host, or private subnet IP
  static bool isLocalHost(String host) {
    if (localHosts.contains(host)) return true;
    if (host.startsWith('192.168.') || host.startsWith('10.') || host.startsWith('172.')) {
      return true;
    }
    return false;
  }
}
