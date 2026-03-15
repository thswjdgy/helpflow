import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/ticket_model.dart';
import 'app.dart';

/// 앱 진입점
/// 1. Flutter 바인딩 초기화
/// 2. Hive 초기화 및 TypeAdapter 등록
/// 3. ProviderScope로 감싸서 Riverpod 활성화
Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩 초기화 (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 로컬 DB 초기화 (앱 문서 디렉토리에 저장)
  await Hive.initFlutter();

  // TicketModel 및 관련 열거형 TypeAdapter 등록
  // (ticket_model.g.dart는 build_runner로 생성된 어댑터 사용)
  Hive.registerAdapter(TicketModelAdapter());
  Hive.registerAdapter(TicketStatusAdapter());
  Hive.registerAdapter(TicketPriorityAdapter());

  // ProviderScope: Riverpod 전역 상태 관리 활성화
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

// [파일 요약]
// 앱 진입점(main.dart)입니다.
// Hive.initFlutter()로 로컬 DB를 초기화하고, TicketModel/TicketStatus/TicketPriority
// TypeAdapter를 등록합니다. ProviderScope로 앱 전체를 감싸 Riverpod을 활성화합니다.
