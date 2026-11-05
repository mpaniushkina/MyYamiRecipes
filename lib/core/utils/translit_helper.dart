class TranslitHelper {
  // Словарь замен: сначала длинные сочетания, потом одиночные буквы
  static final Map<String, String> _translitMap = {
    // Длинные сочетания
    'shch': 'щ', 'Sch': 'Щ', 'SHCH': 'Щ',
    'sh': 'ш', 'Sh': 'Ш', 'SH': 'Ш',
    'ch': 'ч', 'Ch': 'Ч', 'CH': 'Ч',
    'zh': 'ж', 'Zh': 'Ж', 'ZH': 'Ж',
    'yu': 'ю', 'Yu': 'Ю', 'YU': 'Ю',
    'ya': 'я', 'Ya': 'Я', 'YA': 'Я',
    'yo': 'ё', 'Yo': 'Ё', 'YO': 'Ё',
    'ts': 'ц', 'Ts': 'Ц', 'TS': 'Ц',
    'kh': 'х', 'Kh': 'Х', 'KH': 'Х',
    'ph': 'ф', 'Ph': 'Ф', 'PH': 'Ф',

    // Одиночные буквы (латиница -> кириллица)
    'a': 'а', 'A': 'А',
    'b': 'б', 'B': 'Б',
    'v': 'в', 'V': 'В',
    'g': 'г', 'G': 'Г',
    'd': 'д', 'D': 'Д',
    'e': 'е', 'E': 'Е',
    'z': 'з', 'Z': 'З',
    'i': 'и', 'I': 'И',
    'j': 'й', 'J': 'Й',
    'k': 'к', 'K': 'К',
    'l': 'л', 'L': 'Л',
    'm': 'м', 'M': 'М',
    'n': 'н', 'N': 'Н',
    'o': 'о', 'O': 'О',
    'p': 'п', 'P': 'П',
    'r': 'р', 'R': 'Р',
    's': 'с', 'S': 'С',
    't': 'т', 'T': 'Т',
    'u': 'у', 'U': 'У',
    'f': 'ф', 'F': 'Ф',
    'h': 'х', 'H': 'Х',
    'y': 'ы', 'Y': 'Ы',
    'w': 'в', 'W': 'В',
    'c': 'к', 'C': 'С',
    'x': 'кс', 'X': 'КС',
  };

  // 1. Словарь точечных исправлений для самых частых кулинарных опечаток OCR
  static String _fixCommonOcrEndings(String text) {
    // Можно дописывать правила для частых кулинарных окончаний
    return text
        .replaceAll('ТВОРОКНОЕ', 'творожное')
        .replaceAll('творокное', 'творожное')
        .replaceAll('Творокное', 'Творожное')
        .replaceAll('печение', 'печенье')
        .replaceAll('Печение', 'Печенье');
  }

  static final Map<String, String> _latinToCyrillicHomoglyphs = {
    'A': 'А',
    'B': 'В',
    'C': 'С',
    'E': 'Е',
    'H': 'Н',
    'K': 'К',
    'M': 'М',
    'O': 'О',
    'P': 'Р',
    'T': 'Т',
    'X': 'Х',
    'Y': 'У',
    'a': 'а',
    'c': 'с',
    'e': 'е',
    'o': 'о',
    'p': 'р',
    'x': 'х',
    'y': 'у',
    'r': 'г', // Очень часто в словах на конце ('or' вместо 'ог') OCR путает 'r' с 'г'
  };

  static String toCyrillic(String input) {
    if (input.isEmpty) return input;

    String result = input;

    // Шаг 1. Сначала обрабатываем длинные буквосочетания (sh, ch, yu и т.д.)
    // Сортируем ключи по убыванию длины, чтобы 'shch' заменялось раньше, чем 'sh'
    final keys = _translitMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (var key in keys) {
      if (key.length > 1) {
        result = result.replaceAll(key, _translitMap[key]!);
      }
    }

    // Шаг 2. Побуквенная замена оставшихся латинских символов на кириллицу
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < result.length; i++) {
      String char = result[i];
      if (_translitMap.containsKey(char)) {
        buffer.write(_translitMap[char]);
      } else {
        buffer.write(char);
      }
    }

    String cyrillicResult = buffer.toString();

    // Шаг 3. Пост-обработка специфических искажений OCR (когда смешиваются регистры)
    // Например, исправляем кривые окончания вроде "oe" -> "ое", "ne" -> не и т.д.
    cyrillicResult = _fixCommonOcrEndings(cyrillicResult);

    return cyrillicResult;
  }

  /// Главный метод очистки сырого OCR-текста
  // static String normalize(String rawText) {
  //   if (rawText.isEmpty) return rawText;
  //
  //   List<String> words = rawText.split(RegExp(r'\s+'));
  //   List<String> correctedWords = [];
  //
  //   for (var word in words) {
  //     // Шаг 1: Заменяем латинские похожие буквы на русские
  //     String fixedWord = _fixHomoglyphs(word);
  //
  //     // Шаг 2: Проверяем по словарю известных ошибок (приводим к нижнему регистру для сверки)
  //     String lowerKey = fixedWord.toLowerCase().replaceAll(RegExp(r'[^\wа-яё]'), '');
  //     if (_knownCorrections.containsKey(lowerKey)) {
  //       fixedWord = _knownCorrections[lowerKey]!;
  //     }
  //
  //     correctedWords.add(fixedWord);
  //   }
  //
  //   return correctedWords.join(' ');
  // }

  /// Замена латинских букв на русские внутри слова
  static String _fixHomoglyphs(String word) {
    // Проверяем, есть ли в слове хоть одна русская буква.
    // Если да, то латинские буквы в нем — это почти наверняка ошибка OCR.
    bool hasCyrillic = RegExp(r'[а-яёА-ЯЁ]').hasMatch(word);

    if (!hasCyrillic) return word; // Если слово полностью английское, не трогаем

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      // Если буква латинская и у нее есть кириллический двойник — заменяем
      if (_latinToCyrillicHomoglyphs.containsKey(char)) {
        buffer.write(_latinToCyrillicHomoglyphs[char]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}