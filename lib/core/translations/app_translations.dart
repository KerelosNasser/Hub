import 'package:get/get_navigation/src/root/internacionalization.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'title': "Farah's Hub",
      'notes': 'Notes',
      'lessons': 'Lessons',
      'ai_tools': 'AI Tools',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'error': 'Error',
      'success': 'Success',
      'confirm': 'Confirm',
      'loading': 'Loading...',
    },
    'ar': {
      'title': 'مركز فرح',
      'notes': 'ملاحظات',
      'lessons': 'دروس',
      'ai_tools': 'أدوات الذكاء الاصطناعي',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'error': 'خطأ',
      'success': 'نجاح',
      'confirm': 'تأكيد',
      'loading': 'جاري التحميل...',
    },
  };
}