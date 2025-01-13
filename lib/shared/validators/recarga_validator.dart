class RechargeValidator {
  String? validate(String value) {
    if (value.isEmpty) {
      return 'O valor é obrigatório';
    }

    double? amount = double.tryParse(value);

    if (amount == null) {
      return 'Insira um valor válido';
    }

    if (amount <= 0) {
      return 'O valor deve ser maior que 0';
    }

    if (amount < 0) {
      return 'O valor não pode ser negativo';
    }

    return null;
  }
}
