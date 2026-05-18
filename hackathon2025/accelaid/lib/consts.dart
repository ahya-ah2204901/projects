import 'package:flutter_dotenv/flutter_dotenv.dart';

late final String OPENAI_API_K = dotenv.env['OPENAI_API_KEY'] ?? '';
