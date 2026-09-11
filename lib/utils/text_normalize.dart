const _withDiacritics = 'àâäáãåèéêëìíîïòóôöõùúûüçñ';
const _withoutDiacritics = 'aaaaaaeeeeiiiioooooouuuucn';

/// Met en minuscules et retire les diacritiques (accents, cédille...), pour
/// des recherches insensibles aux accents : "degustation" doit trouver
/// "dégustation", "tregunc" doit trouver "Trégunc".
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = _withDiacritics.indexOf(char);
    buffer.write(index >= 0 ? _withoutDiacritics[index] : char);
  }
  return buffer.toString();
}
