import 'package:flutter/material.dart';

import '../presentation/assessment_quiz_screen/assessment_quiz_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/ai_chat_screen/ai_chat_screen.dart';
import '../presentation/course_catalog_screen/course_catalog_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/course_detail_screen/course_detail_screen.dart';
import '../presentation/learning_content_screen/learning_content_screen.dart';
import '../presentation/quiz_screen/quiz_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String assessmentQuiz = '/assessment-quiz-screen';
  static const String dashboard = '/dashboard-screen';
  static const String aiChat = '/ai-chat-screen';
  static const String courseCatalog = '/course-catalog-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String profile = '/profile-screen';
  static const String registration = '/registration-screen';
  static const String login = '/login-screen';
  static const String courseDetail = '/course-detail-screen';
  static const String learningContent = '/learning-content-screen';
  static const String quiz = '/quiz-screen';

  // 👇 Initial route (first screen)

  // Routes map
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    assessmentQuiz: (context) => const AssessmentQuizScreen(),
    dashboard: (context) => const DashboardScreen(),
    aiChat: (context) => const AiChatScreen(),
    courseCatalog: (context) => const CourseCatalogScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    profile: (context) => const ProfileScreen(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    courseDetail: (context) => const CourseDetailScreen(),
    learningContent: (context) => const LearningContentScreen(),
    quiz: (context) => const QuizScreen(),
  };
}
