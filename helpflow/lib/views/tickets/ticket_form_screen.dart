import 'package:flutter/material.dart';

/// 티켓 작성/수정 폼 화면
/// /tickets/new 경로: 새 티켓 작성
/// TODO: 2주차에 실제 폼 입력 및 Hive 저장 기능 구현 예정
class TicketFormScreen extends StatelessWidget {
  const TicketFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('티켓 작성 화면'),
      ),
    );
  }
}

// [파일 요약]
// 새 티켓 작성 또는 기존 티켓 수정을 위한 폼 화면의 뼈대입니다.
// 2주차에 제목/설명/우선순위 입력 폼 및 Hive 저장 기능이 추가될 예정입니다.
