import 'api_client.dart';

class PaymentResult {
  final String id;
  final bool approved;
  PaymentResult({required this.id, required this.approved});
}

class PaymentService {
  final ApiClient _api = ApiClient();

  Future<PaymentResult> charge({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    final response = await _api.post('/payments', {
      'cardNumber': cardNumber,
      'cvv': cvv,
      'expMonth': expMonth,
      'expYear': expYear,
      if (cardholder != null && cardholder.isNotEmpty) 'cardholder': cardholder,
    }, auth: true);

    final data = response is Map && response.containsKey('data')
        ? response['data']
        : response;

    return PaymentResult(
      id: (data['id'] ?? data['paymentId'] ?? '').toString(),
      approved: true,
    );
  }
}
