/// Holds all user-configurable options for password generation.
class PasswordOptions {
  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useNumbers;
  final bool useSymbols;

  const PasswordOptions({
    this.length = 16,
    this.useUppercase = true,
    this.useLowercase = true,
    this.useNumbers = true,
    this.useSymbols = true,
  });

  /// Returns true if at least one character type is selected.
  bool get isValid =>
      useUppercase || useLowercase || useNumbers || useSymbols;

  /// The total character pool size based on selected options.
  int get poolSize {
    int size = 0;
    if (useUppercase) size += 26;
    if (useLowercase) size += 26;
    if (useNumbers) size += 10;
    if (useSymbols) size += 32;
    return size;
  }

  /// Number of active character type categories.
  int get activeCategories {
    int count = 0;
    if (useUppercase) count++;
    if (useLowercase) count++;
    if (useNumbers) count++;
    if (useSymbols) count++;
    return count;
  }

  PasswordOptions copyWith({
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useNumbers,
    bool? useSymbols,
  }) {
    return PasswordOptions(
      length: length ?? this.length,
      useUppercase: useUppercase ?? this.useUppercase,
      useLowercase: useLowercase ?? this.useLowercase,
      useNumbers: useNumbers ?? this.useNumbers,
      useSymbols: useSymbols ?? this.useSymbols,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PasswordOptions &&
      length == other.length &&
      useUppercase == other.useUppercase &&
      useLowercase == other.useLowercase &&
      useNumbers == other.useNumbers &&
      useSymbols == other.useSymbols;

  @override
  int get hashCode => Object.hash(
        length,
        useUppercase,
        useLowercase,
        useNumbers,
        useSymbols,
      );
}
