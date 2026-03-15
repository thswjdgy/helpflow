/// 앱 전체에서 사용하는 날짜/시간 유틸리티 함수 모음
/// Flutter 내장 DateUtils와 충돌하지 않도록 AppDateUtils로 명명
class AppDateUtils {
  AppDateUtils._(); // 인스턴스 생성 방지

  /// DateTime을 'YYYY-MM-DD' 형식으로 포맷
  /// 예: 2026-03-15
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// DateTime을 'YYYY-MM-DD HH:mm' 형식으로 포맷
  /// 예: 2026-03-15 14:30
  static String formatDateTime(DateTime date) {
    final dateStr = formatDate(date);
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$dateStr $h:$min';
  }

  /// 상대적 시간 표시 (예: '3분 전', '2시간 전', '어제')
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return formatDate(date);
    }
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// [파일 요약]
// 앱 전체에서 사용하는 날짜 포맷(YYYY-MM-DD, HH:mm),
// 상대 시간 표시(N분 전/어제 등), 오늘 날짜 판별 유틸리티를 제공합니다.
// Flutter 내장 DateUtils와의 네임 충돌 방지를 위해 AppDateUtils로 명명합니다.
