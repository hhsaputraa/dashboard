import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/core/security/url_security_validator.dart';

void main() {
  group('UrlSecurityValidator Tests', () {
    test('rejects empty or whitespace URLs', () {
      final resultEmpty = UrlSecurityValidator.validate('');
      expect(resultEmpty.isValid, isFalse);
      expect(resultEmpty.errorMessage, contains('tidak boleh kosong'));

      final resultWhitespace = UrlSecurityValidator.validate('   ');
      expect(resultWhitespace.isValid, isFalse);
    });

    test('rejects malformed URLs without scheme or host', () {
      final result1 = UrlSecurityValidator.validate('localhost:8097');
      expect(result1.isValid, isFalse);
      expect(result1.errorMessage, contains('Format URL tidak valid'));

      final result2 = UrlSecurityValidator.validate('ftp://my-server.com');
      expect(result2.isValid, isFalse);
      expect(result2.errorMessage, contains('tidak didukung'));
    });

    test('allows HTTP for local development and emulator addresses', () {
      final local1 = UrlSecurityValidator.validate('http://localhost:8097');
      expect(local1.isValid, isTrue);
      expect(local1.isSecureHttps, isFalse);

      final local2 = UrlSecurityValidator.validate('http://127.0.0.1:8097');
      expect(local2.isValid, isTrue);

      final emulator = UrlSecurityValidator.validate('http://10.0.2.2:8097');
      expect(emulator.isValid, isTrue);

      final privateNetwork = UrlSecurityValidator.validate('http://192.168.1.50:8097');
      expect(privateNetwork.isValid, isTrue);
    });

    test('rejects insecure HTTP for public/remote domains by default', () {
      final remoteHttp = UrlSecurityValidator.validate('http://api.bprsupra.co.id:8097');
      expect(remoteHttp.isValid, isFalse);
      expect(remoteHttp.errorMessage, contains('wajib menggunakan HTTPS'));
    });

    test('accepts HTTPS for public/remote domains', () {
      final remoteHttps = UrlSecurityValidator.validate('https://api.bprsupra.co.id:8097');
      expect(remoteHttps.isValid, isTrue);
      expect(remoteHttps.isSecureHttps, isTrue);
      expect(remoteHttps.errorMessage, isNull);
    });
  });
}
