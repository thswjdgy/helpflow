/// 앱 전체에서 사용하는 입력값 검증(Validation) 함수 모음
/// Form 필드의 validator 파라미터에 직접 전달 가능
class AppValidators {
  AppValidators._(); // 인스턴스 생성 방지

  /// 필수 입력값 검증 (빈 값 방지)
  static String? required(String? value, {String fieldName = '이 항목'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요.';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? Function(String?) minLength(int min, {String fieldName = '입력값'}) {
    return (String? value) {
      if (value == null || value.trim().length < min) {
        return '$fieldName은(는) 최소 $min자 이상이어야 합니다.';
      }
      return null;
    };
  }

  /// 최대 길이 검증
  static String? Function(String?) maxLength(int max, {String fieldName = '입력값'}) {
    return (String? value) {
      if (value != null && value.trim().length > max) {
        return '$fieldName은(는) 최대 $max자까지 입력 가능합니다.';
      }
      return null;
    };
  }

  /// 이메일 형식 검증
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '올바른 이메일 형식을 입력해주세요.';
    }
    return null;
  }

  /// 여러 검증 함수를 순서대로 실행 (첫 오류에서 중단)
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

// [파일 요약]
// Form 필드에 사용할 입력값 검증 함수들을 제공합니다.
// required, minLength, maxLength, email 검증 및 compose()로 복합 검증을 지원합니다.
