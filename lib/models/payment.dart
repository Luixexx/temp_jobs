class Payment {
  final String id;
  final num amount;
  final String currency;
  final String status; // approved, rejected
  final String? cardLast4;
  final String? createdAt;
  final String? offerId;

  Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.cardLast4,
    this.createdAt,
    this.offerId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // El número de tarjeta puede venir completo o ya enmascarado; nos
    // quedamos solo con los últimos 4 dígitos, por las dudas.
    final rawCard = json['cardNumber'] ?? json['card'] ?? json['last4'];
    String? last4;
    if (rawCard != null) {
      final digits = rawCard.toString().replaceAll(RegExp(r'[^0-9]'), '');
      last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    }

    return Payment(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'approved',
      cardLast4: last4,
      createdAt: json['createdAt'],
      offerId: json['offerId']?.toString(),
    );
  }
}
