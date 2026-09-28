class PresetDemoPhoto {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String extractedText;
  final bool isArabic;

  const PresetDemoPhoto({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.extractedText,
    this.isArabic = false,
  });

  static const List<PresetDemoPhoto> englishSamples = [
    PresetDemoPhoto(
      id: 'book_quote',
      title: 'Classic Literature Excerpt',
      category: 'Book Page',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. However little known the feelings or views of such a man may be on his first entering a neighbourhood.',
    ),
    PresetDemoPhoto(
      id: 'billboard_quote',
      title: 'Inspirational Street Sign',
      category: 'Signboard',
      imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'The future belongs to those who believe in the beauty of their dreams. Start each day with a grateful heart, work with relentless passion, and never surrender your vision.',
    ),
    PresetDemoPhoto(
      id: 'cafe_menu',
      title: 'Artisan Cafe Special',
      category: 'Menu Board',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'Daily Special: Double-shot Velvet Espresso with caramel drizzle, paired with freshly baked almond croissants and wild honey. Brewed with love every morning.',
    ),
    PresetDemoPhoto(
      id: 'tech_news',
      title: 'Science & AI Breakthrough',
      category: 'Article',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'Breakthrough in neural voice synthesis allows real-time text-to-speech conversion from any visual document with human-level natural prosody and emotional cadence.',
    ),
  ];

  static const List<PresetDemoPhoto> arabicSamples = [
    PresetDemoPhoto(
      id: 'ar_wisdom',
      title: 'حكمة شعرية ملهمة',
      category: 'شعر عربي',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'وما نيل المطالب بالتمني، ولكن تؤخذ الدنيا غلابا. وما استعصى على قوم منال، إذا الإقدام كان لهم ركابا. كن جميلاً تر الوجود جميلا.',
      isArabic: true,
    ),
    PresetDemoPhoto(
      id: 'ar_motivation',
      title: 'لوحة تحفيز وتفاؤل',
      category: 'إشراقة أمل',
      imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'المستقبل ملك لأولئك الذين يؤمنون بجمال أحلامهم. ابدأ يومك بقلب شاكر، واعمل بشغف لا يلين، ولا تستسلم أبداً أمام التحديات، فالقادم أجمل دائماً بإذن الله.',
      isArabic: true,
    ),
    PresetDemoPhoto(
      id: 'ar_cafe',
      title: 'قائمة المقهى العربي',
      category: 'مقهى أصيل',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'المشروب الخاص اليوم: قهوة عربية شقراء بالهيل والزعفران، تُقدم مع تمر خلاص فاخر وحلوى السمسم الطازجة. أهلاً وسهلاً بكم في مقهانا الأصيل.',
      isArabic: true,
    ),
    PresetDemoPhoto(
      id: 'ar_tech',
      title: 'ثورة الذكاء الاصطناعي',
      category: 'تقنية المستقبل',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'إنجاز جديد في تقنيات الذكاء الاصطناعي يتيح تحويل المستندات المصورة والنصوص العربية إلى أصوات بشرية طبيعية بنبرات رجالية ونسائية عالية الدقة والفصاحة.',
      isArabic: true,
    ),
  ];

  static List<PresetDemoPhoto> getSamples(bool isArabic) {
    return isArabic ? arabicSamples : englishSamples;
  }
}
