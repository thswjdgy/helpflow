import 'package:flutter/material.dart';
import '../../core/design_system.dart';

/// 티켓 상세 화면
/// ticketId를 통해 특정 티켓의 상세 정보를 표시
/// TODO: 2주차에 Hive 연동 및 상태 변경 기능 구현 예정
class TicketDetailScreen extends StatelessWidget {
  /// 라우트 파라미터로 전달받은 티켓 고유 ID
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 디자인 시스템 배경색 통일
      backgroundColor: HelpFlowColors.background,
      body: Center(
        child: Text('티켓 상세 화면 (ID: $ticketId)'),
      ),
    );
  }
}

// [파일 요약]
// 특정 티켓의 상세 정보를 표시하는 화면의 뼈대입니다.
// go_router의 :id 경로 파라미터를 ticketId로 수신합니다.
// 2주차에 상태 변경, 댓글, 첨부파일 기능이 추가될 예정입니다.
