import 'package:flutter/material.dart';

/// 설정 화면
/// TODO: 다크모드 토글, 알림 설정, 앱 정보 등 추가 예정
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('설정 화면'),
      ),
    );
  }
}

// [파일 요약]
// 앱 설정 화면의 뼈대입니다.
// 추후 다크모드 전환, 알림 설정, 데이터 초기화, 앱 버전 정보 등이 추가될 예정입니다.
