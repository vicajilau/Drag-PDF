import 'package:drag_pdf/helper/helpers.dart';
import 'package:drag_pdf/model/file_read.dart';
import 'package:drag_pdf/view/create_signature_screen.dart';
import 'package:go_router/go_router.dart';

import '../view/home_screen_mobile.dart';
import '../view/pdf_viewer_screen.dart';
import '../view/preview_document_screen.dart';
import '../view/splash_screen.dart';

class AppRouter {
  late final GoRouter _routes;

  static AppRouter shared = AppRouter();

  AppRouter() {
    _routes = _getMobileRoutes();
  }

  GoRouter getRouter() => _routes;

  // Mobile Routing
  GoRouter _getMobileRoutes() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreenMobile(),
            routes: [
              GoRoute(
                  path: 'preview_document_screen',
                  builder: (context, state) =>
                      PreviewDocumentScreen(file: state.extra as FileRead),
                  routes: [
                    GoRoute(
                      path: 'create_signature_screen',
                      builder: (context, state) =>
                          const CreateSignatureScreen(),
                    )
                  ]),
              GoRoute(
                path: 'pdf_viewer_screen',
                builder: (context, state) =>
                    PDFViewerScreen(file: state.extra as FileRead),
              ),
            ]),
        GoRoute(
          path: '/loading',
          builder: (context, state) => const LoadingScreen(),
        ),
      ],
    );
  }
}
