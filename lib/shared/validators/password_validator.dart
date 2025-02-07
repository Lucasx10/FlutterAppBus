class PasswordValidator {
  String? validate({String? password}) {
    if (password == null || password.isEmpty) {
      return 'A senha é obrigatória';
    }

    if (password.length < 6) {
      return 'A senha deve possuir pelo menos 6 caracteres';
    }

    // Expressões regulares para validação
    final containsLowercase = RegExp(r'[a-z]');
    final containsUppercase = RegExp(r'[A-Z]');
    final containsNumber = RegExp(r'[0-9]');
    final containsSpecialChar = RegExp(r'[^a-zA-Z0-9]');

    // Verificação se a senha contém pelo menos uma letra minúscula, maiúscula, número e caractere especial
    if (!containsLowercase.hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }

    if (!containsUppercase.hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }

    if (!containsNumber.hasMatch(password)) {
      return 'A senha deve conter pelo menos um número';
    }

    if (!containsSpecialChar.hasMatch(password)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }

    return null;
  }

  String? validateConfirmPassword({String? password, String? confirmPassword}) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'A confirmação da senha é obrigatória';
    }

    if (password != confirmPassword) {
      return 'As senhas não coincidem';
    }

    return null;
  }
}
