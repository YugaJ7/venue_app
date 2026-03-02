String getFriendlyErrorMessage(String rawError) {
  if (rawError.contains('user-not-found') ||
      rawError.contains('No user found')) {
    return 'No account found for this email.';
  } else if (rawError.contains('wrong-password') ||
             rawError.contains('incorrect')) {
    return 'Incorrect user credentials. Please try again.';
  } else if (rawError.contains('invalid-email')) {
    return 'Please enter a valid email address.';
  } else if (rawError.contains('too-many-requests')) {
    return 'Too many attempts. Try again later.';
  } else if (rawError.contains('user-disabled')) {
    return 'This account has been disabled.';
  } else if (rawError.contains('email address is already in use')) {
    return 'This email is already registered.';
  } else if (rawError.contains('weak-password')) {
    return 'Your password is too weak.';
  } else if (rawError.contains('network error')) {
    return 'Network error. Please check your connection.';
  } else {
    return 'Something went wrong. Please try again.';
  }
}
