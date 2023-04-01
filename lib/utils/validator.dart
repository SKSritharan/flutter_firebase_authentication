class Validator {
  static validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'The Email Address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format.';
    }
    return null;
  }

  static validatePassword(String value) {
    if (value.trim().isEmpty) {
      return 'The Password is required';
    } else if (value.trim().length < 8) {
      return 'The Password must be at least 8 characters long.';
    }
    return null;
  }

  static validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }
}
