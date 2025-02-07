class EmailValidator {
  String? validate({String? email}) {
    if (email == null || email.isEmpty) {
      return 'O e-mail é obrigatório';
    }

    // Expressão regular para validar o formato do e-mail
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false, // Torna a regex case-insensitive
    );

    if (!emailRegex.hasMatch(email)) {
      return 'O e-mail é inválido';
    }

    return null;
  }
}
