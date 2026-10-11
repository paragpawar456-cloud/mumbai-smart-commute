// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मुंबई स्मार्ट कम्यूट';

  @override
  String get navHome => 'होम';

  @override
  String get navRoutes => 'रूट';

  @override
  String get navMap => 'मैप';

  @override
  String get navSaved => 'सेव्ड';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get homeGreeting => 'आप कहाँ जा रहे हैं?';

  @override
  String get fromLabel => 'कहाँ से';

  @override
  String get toLabel => 'कहाँ तक';

  @override
  String get fromHint => 'मौजूदा जगह या स्टेशन';

  @override
  String get toHint => 'मंज़िल, जैसे योगीधाम, कल्याण पश्चिम';

  @override
  String get findRoutes => 'रूट खोजें';

  @override
  String get nearbyTransport => 'आस-पास का परिवहन';

  @override
  String get nearbyTransportBody =>
      'आपके पास के स्टेशन, बस स्टॉप और ऑटो स्टैंड';

  @override
  String get savedJourneys => 'सेव की गई यात्राएँ';

  @override
  String get noSavedJourneys =>
      'अभी कोई यात्रा सेव नहीं है। रूट खोजें और सेव करने के लिए स्टार दबाएँ।';

  @override
  String get routesTitle => 'यात्रा की योजना';

  @override
  String get routesComingSoon =>
      'लोकल, मेट्रो और बस की समय-सारणी अगले अपडेट में आएगी।';

  @override
  String get mapTitle => 'मैप';

  @override
  String get mapComingSoon =>
      'मैप अगले अपडेट में आएगा। वाहन तभी लाइव दिखेंगे जब असली लाइव डेटा उपलब्ध हो।';

  @override
  String get savedTitle => 'सेव्ड';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get reducedMotion => 'एनिमेशन कम करें';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get register => 'खाता बनाएँ';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get displayName => 'नाम';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get resetEmailSent =>
      'अगर उस ईमेल का खाता है, तो रीसेट लिंक भेज दिया गया है।';

  @override
  String get verifyEmailSent => 'आपके ईमेल पर सत्यापन लिंक भेजा गया है।';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get continueAsGuest => 'बिना खाते के जारी रखें';

  @override
  String get guestNote =>
      'बिना खाते के भी समय-सारणी और मैप इस्तेमाल कर सकते हैं। रूट सेव करने और जानकारी भेजने के लिए साइन इन करें।';

  @override
  String signedInAs(String email) {
    return '$email के रूप में साइन इन';
  }

  @override
  String get notSignedIn => 'साइन इन नहीं किया';

  @override
  String get authUnavailable => 'इस बिल्ड में साइन-इन चालू नहीं है।';

  @override
  String get deleteAccount => 'खाता हटाएँ';

  @override
  String get deleteAccountConfirm =>
      'इससे आपका खाता और सेव किया डेटा हमेशा के लिए हट जाएगा। जारी रखें?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get offline => 'आप ऑफ़लाइन हैं। सेव की गई जानकारी दिखा रहे हैं।';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया फिर से कोशिश करें।';

  @override
  String get errorNetwork =>
      'सर्वर से संपर्क नहीं हो सका। अपना कनेक्शन जाँचें।';

  @override
  String get backendStatus => 'सर्वर स्थिति';

  @override
  String get backendOk => 'जुड़ा हुआ';

  @override
  String get backendNotConfigured => 'इस बिल्ड में सर्वर सेट नहीं है';

  @override
  String get sourceLive => 'लाइव';

  @override
  String get sourceScheduled => 'समय-सारणी के अनुसार';

  @override
  String get sourceEstimate => 'अनुमान';

  @override
  String get sourceOfficial => 'आधिकारिक';

  @override
  String get sourceCommunity => 'यात्रियों द्वारा बताया गया';

  @override
  String get sourceUnknown => 'अज्ञात';

  @override
  String updatedAt(String time) {
    return '$time पर अपडेट';
  }

  @override
  String get about => 'जानकारी और डेटा स्रोत';

  @override
  String get aboutBody =>
      'मैप डेटा © OpenStreetMap योगदानकर्ता। \'अनुमान\' वाले किराए आधिकारिक दरों से निकाले गए हैं, ये लाइव दर नहीं हैं। यह ऐप आपातकालीन सेवा नहीं है।';

  @override
  String get selectStation => 'स्टेशन चुनें';

  @override
  String get searchStations => 'स्टेशन खोजें';

  @override
  String get noStationFound => 'स्टेशन नहीं मिला। दूसरी स्पेलिंग आज़माएँ।';

  @override
  String get planJourney => 'यात्रा खोजें';

  @override
  String get noRouteFound => 'इन स्टेशनों के बीच रूट नहीं मिला।';

  @override
  String get chooseBothStations => 'शुरुआत और मंज़िल का स्टेशन चुनें।';

  @override
  String rideLeg(String line) {
    return '$line';
  }

  @override
  String boardAt(String station) {
    return '$station पर चढ़ें';
  }

  @override
  String alightAt(String station) {
    return '$station पर उतरें';
  }

  @override
  String stopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्टॉप',
      one: '1 स्टॉप',
    );
    return '$_temp0';
  }

  @override
  String changesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदलाव',
      one: '1 बदलाव',
      zero: 'सीधा',
    );
    return '$_temp0';
  }

  @override
  String walkTo(String station, int minutes) {
    return '$station तक पैदल (लगभग $minutes मि.)';
  }

  @override
  String get timetableNotLoaded =>
      'समय-सारणी अभी जोड़ी नहीं गई है। आधिकारिक समय-सारणी जुड़ने पर ट्रेन के समय दिखेंगे। हम कभी अंदाज़े से समय नहीं दिखाते।';

  @override
  String nextTrain(String dep, String arr) {
    return 'अगली ट्रेन $dep → पहुँचेगी $arr';
  }

  @override
  String get noMoreTrainsToday =>
      'इस यात्रा के लिए आज और कोई निर्धारित ट्रेन नहीं है।';

  @override
  String get departures => 'प्रस्थान';

  @override
  String towards(String station) {
    return '$station की ओर';
  }

  @override
  String platformShort(String platform) {
    return 'PF $platform';
  }

  @override
  String get fastTrain => 'फ़ास्ट';

  @override
  String get slowTrain => 'स्लो';

  @override
  String get acTrain => 'एसी';

  @override
  String get ladiesTrain => 'महिला';

  @override
  String get saveJourney => 'यात्रा सेव करें';

  @override
  String get removeJourney => 'सेव से हटाएँ';

  @override
  String get recentSearches => 'हाल की खोजें';

  @override
  String dataVersion(int version, String origin) {
    return 'डेटा संस्करण $version · $origin';
  }

  @override
  String get originBundled => 'ऐप में शामिल';

  @override
  String get originCached => 'पहले डाउनलोड किया';

  @override
  String get originServer => 'अभी अपडेट हुआ';

  @override
  String get showOnMap => 'मैप पर दिखाएँ';

  @override
  String get myLocation => 'मेरी जगह';

  @override
  String get layers => 'परतें';

  @override
  String get layerSuburban => 'लोकल ट्रेन';

  @override
  String get layerMetro => 'मेट्रो';

  @override
  String get locationDenied =>
      'लोकेशन अनुमति बंद है। मैप फिर भी चलेगा; अपनी जगह देखने के लिए सेटिंग्स में चालू करें।';

  @override
  String get locationServiceOff => 'इस फ़ोन पर लोकेशन बंद है।';

  @override
  String get lineGeometryNote =>
      'लाइनें स्टेशनों के बीच सीधी दिखाई गई हैं, सटीक पटरी पर नहीं।';

  @override
  String get linesAtStation => 'लाइनें';
}
