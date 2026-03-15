import 'package:flutter/material.dart';

/// 티켓 목록 화면
/// TODO: 2주차에 Hive 연동 및 실제 티켓 목록 구현 예정
class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('티켓 관리 화면'),
      ),
    );
  }
}

// [파일 요약]
// 티켓 목록을 표시하는 화면의 뼈대입니다.
// 2주차에 Hive 연동 및 필터링/정렬 기능이 추가될 예정입니다.
