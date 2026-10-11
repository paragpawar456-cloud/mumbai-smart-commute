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

  @override
  String get lastMileTitle => 'स्टेशन से घर तक';

  @override
  String get lastMileHomeBody =>
      'स्टेशन से आपकी मंज़िल तक पैदल, ऑटो, शेयर ऑटो, बस या कैब';

  @override
  String get lastMileFromStation => 'स्टेशन से';

  @override
  String get lastMileTo => 'कहाँ जाना है';

  @override
  String get lastMileToHint => 'जगह खोजें या नक्शे पर चुनें';

  @override
  String get lastMilePickOnMap => 'नक्शे पर चुनें';

  @override
  String get lastMileUseThisPoint => 'यह जगह चुनें';

  @override
  String get lastMileDroppedPin => 'नक्शे पर चुनी जगह';

  @override
  String get lastMileChooseDestination =>
      'विकल्प देखने के लिए चुनें कि आप कहाँ जा रहे हैं।';

  @override
  String get lastMileFromHere => 'यहाँ से आगे का सफ़र';

  @override
  String get searchPlaces => 'जगह खोजें';

  @override
  String get noPlaceFound => 'ऐसी जगह अभी नहीं है। नक्शे पर जगह चुनकर देखें।';

  @override
  String get sortCheapest => 'सबसे सस्ता';

  @override
  String get sortFastest => 'सबसे तेज़';

  @override
  String get sortLeastWalking => 'कम पैदल';

  @override
  String distanceStraight(String km) {
    return 'सीधी रेखा में $km किमी';
  }

  @override
  String distanceRoadEstimate(String km) {
    return 'सड़क से लगभग $km किमी (अनुमान)';
  }

  @override
  String distanceRoad(String km) {
    return 'सड़क से $km किमी';
  }

  @override
  String get optWalk => 'पैदल';

  @override
  String get optAutoMeter => 'ऑटो (मीटर से)';

  @override
  String get optTaxiMeter => 'काली-पीली टैक्सी (मीटर से)';

  @override
  String get optSharedAuto => 'शेयर ऑटो';

  @override
  String optBus(String operator, String number) {
    return '$operator बस $number';
  }

  @override
  String fareFrom(int amount) {
    return '₹$amount से';
  }

  @override
  String fareAbout(int amount) {
    return '≈ ₹$amount';
  }

  @override
  String fareShared(int amount) {
    return 'प्रति सीट ₹$amount';
  }

  @override
  String get fareUnknown => 'किराया पता नहीं';

  @override
  String get fareInApp => 'कीमत उनके ऐप में';

  @override
  String minutesAbout(int minutes) {
    return 'बिना ट्रैफ़िक लगभग $minutes मिनट';
  }

  @override
  String walkMeters(int meters) {
    return '$meters मी पैदल';
  }

  @override
  String get nightFareApplied => 'रात का अतिरिक्त किराया शामिल';

  @override
  String nearestStand(String name, int meters) {
    return 'नज़दीकी स्टैंड: $name, $meters मी';
  }

  @override
  String get noStandKnown => 'स्टेशन के पास अभी कोई स्टैंड दर्ज नहीं';

  @override
  String busBoardAlight(String board, String alight) {
    return '$board पर चढ़ें, $alight पर उतरें';
  }

  @override
  String get availabilityUnknown => 'अभी वाहन है या नहीं, यह हमें नहीं दिखता।';

  @override
  String openApp(String name) {
    return '$name खोलें';
  }

  @override
  String get couldNotOpen => 'ऐप नहीं खुल सका।';

  @override
  String get howWeEstimate => 'ये आंकड़े कैसे निकाले गए';

  @override
  String get assumptionsBody =>
      'सड़क मार्ग उपलब्ध न हो तो दूरी = सीधी रेखा × 1.3। समय: पैदल 4.5 किमी/घंटा, ऑटो 18 किमी/घंटा, टैक्सी 20 किमी/घंटा; ट्रैफ़िक या इंतज़ार शामिल नहीं। मीटर किराया प्रकाशित दर से है; असली किराया मीटर तय करता है।';

  @override
  String fareRuleSource(String mode, String source, String date) {
    return '$mode: दरें $source, $date से लागू';
  }

  @override
  String get noFareRules =>
      'किराया दरें अभी दर्ज नहीं हैं, इसलिए मीटर किराए का अनुमान नहीं दे सकते।';

  @override
  String get nearbyPickups => 'स्टेशन के पास के स्टैंड';

  @override
  String get nearbyPickupsEmpty => 'इस स्टेशन के पास अभी कोई स्टैंड दर्ज नहीं।';

  @override
  String get verificationAdmin => 'हमने जाँचा';

  @override
  String get verificationOsm => 'OpenStreetMap से';

  @override
  String get verificationCommunity => 'यात्रियों ने बताया';

  @override
  String get communityReports => 'यात्रियों की रिपोर्ट';

  @override
  String get communityReportsEmpty => 'इस स्टेशन के पास अभी कोई रिपोर्ट नहीं।';

  @override
  String get communityReportsOffline =>
      'रिपोर्ट के लिए सर्वर चाहिए, जो अभी सेट नहीं है।';

  @override
  String get reportSomething => 'रिपोर्ट करें';

  @override
  String get reportWhere => 'कहाँ';

  @override
  String get reportTypeQueue => 'लंबी कतार';

  @override
  String get reportTypeNoVehicles => 'ऑटो/टैक्सी नहीं';

  @override
  String get reportTypeStandMoved => 'स्टैंड हट गया है';

  @override
  String get reportTypeStopIssue => 'बस स्टॉप की समस्या';

  @override
  String get reportTypeClosure => 'सड़क बंद';

  @override
  String get reportTypeDisruption => 'बाधा';

  @override
  String get reportNoteHint => 'छोटा नोट (वैकल्पिक)';

  @override
  String get reportPrivacy =>
      'दूसरों को रिपोर्ट और जगह दिखती है, आपका नाम या खाता कभी नहीं।';

  @override
  String get reportSubmit => 'रिपोर्ट भेजें';

  @override
  String get reportSent => 'धन्यवाद। रिपोर्ट समाप्त होने तक दूसरों को दिखेगी।';

  @override
  String get reportConfirm => 'अब भी सही';

  @override
  String reportConfirmed(int count) {
    return '$count ने पुष्टि की';
  }

  @override
  String reportAgo(int minutes) {
    return '$minutes मिनट पहले';
  }
}
