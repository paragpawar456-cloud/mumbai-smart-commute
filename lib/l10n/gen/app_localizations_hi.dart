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
  String get fromHint => 'आपकी जगह, स्टेशन या इलाका';

  @override
  String get toHint => 'स्टेशन, इलाका या इमारत, जैसे योगीधाम';

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

  @override
  String get alertSource => 'आधिकारिक स्रोत';

  @override
  String get adminTitle => 'एडमिन';

  @override
  String get adminNoAccess => 'यह भाग एडमिन और मॉडरेटर के लिए है।';

  @override
  String get adminOverview => 'सारांश';

  @override
  String get adminReports => 'रिपोर्ट';

  @override
  String get adminUsers => 'उपयोगकर्ता';

  @override
  String get adminAlerts => 'अलर्ट';

  @override
  String get adminAudit => 'ऑडिट लॉग';

  @override
  String get adminSaved => 'सहेजा गया';

  @override
  String get adminUsersActive => 'सक्रिय उपयोगकर्ता';

  @override
  String get adminUsersDisabled => 'बंद किए गए';

  @override
  String get adminUsersDeleted => 'हटाए गए खाते';

  @override
  String get adminAdmins => 'एडमिन';

  @override
  String get adminModerators => 'मॉडरेटर';

  @override
  String get adminReportsPending => 'समीक्षा के लिए रुकी रिपोर्ट';

  @override
  String get adminReportsLive => 'अभी दिख रही रिपोर्ट';

  @override
  String get adminAlertsActive => 'लागू अलर्ट';

  @override
  String get adminDataPackVersion => 'डेटा पैक संस्करण';

  @override
  String get adminDataPackPublished => 'पिछला प्रकाशन';

  @override
  String get adminRoadDistance => 'सड़क दूरी (openrouteservice)';

  @override
  String get adminOn => 'चालू';

  @override
  String get adminOff => 'बंद';

  @override
  String get adminDataHealth => 'डेटा स्रोत';

  @override
  String get adminNoSync => 'शीट से अभी कुछ प्रकाशित नहीं हुआ।';

  @override
  String adminLastSuccess(String when) {
    return 'पिछली सफलता: $when';
  }

  @override
  String adminAcceptedRejected(int accepted, int rejected) {
    return '$accepted पंक्तियाँ स्वीकार, $rejected अस्वीकार';
  }

  @override
  String get adminNoPending => 'समीक्षा के लिए कोई रिपोर्ट नहीं।';

  @override
  String adminReporter(String uid) {
    return 'खाता $uid ने भेजा';
  }

  @override
  String get adminApprove => 'स्वीकार करें';

  @override
  String get adminReject => 'अस्वीकार करें';

  @override
  String get adminSearchUsers => 'ईमेल या नाम से खोजें';

  @override
  String get adminDisable => 'खाता बंद करें';

  @override
  String get adminEnable => 'खाता चालू करें';

  @override
  String adminMakeRole(String role) {
    return '$role बनाएं';
  }

  @override
  String get adminNewAlert => 'नया अलर्ट';

  @override
  String get adminNoAlerts => 'अभी कोई अलर्ट नहीं।';

  @override
  String get adminEndAlert => 'अभी समाप्त करें';

  @override
  String get adminEnded => 'समाप्त';

  @override
  String get adminRequired => 'ज़रूरी';

  @override
  String get adminAlertScope => 'किस पर लागू';

  @override
  String get adminAlertScopeHelp =>
      'ALL, लाइन कोड (CR-MAIN) या स्टेशन कोड (KYN)';

  @override
  String get adminAlertTitleEn => 'शीर्षक (अंग्रेज़ी)';

  @override
  String get adminAlertTitleMr => 'शीर्षक (मराठी, वैकल्पिक)';

  @override
  String get adminAlertTitleHi => 'शीर्षक (हिंदी, वैकल्पिक)';

  @override
  String get adminAlertBody => 'विवरण (वैकल्पिक)';

  @override
  String get adminAlertSource => 'आधिकारिक घोषणा का लिंक';

  @override
  String get adminAlertSourceHelp =>
      'https:// से शुरू होने वाला आधिकारिक सूचना का लिंक';

  @override
  String get adminAlertStarts => 'शुरू';

  @override
  String get adminAlertEnds => 'समाप्त';

  @override
  String get adminAlertUntilEnded => 'समाप्त करने तक';

  @override
  String get adminPublishAlert => 'अलर्ट प्रकाशित करें';

  @override
  String get roleAdmin => 'आप एडमिन हैं';

  @override
  String get roleModerator => 'आप मॉडरेटर हैं';

  @override
  String get consentPrompt =>
      'यह ऐप आपके बारे में क्या रखता है, यह बताने वाली गोपनीयता सूचना है। कृपया पढ़कर स्वीकार करें।';

  @override
  String get consentRead => 'पढ़ें';

  @override
  String get consentAccept => 'स्वीकार करें';

  @override
  String get privacyTitle => 'गोपनीयता सूचना';

  @override
  String privacyVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get privacyCollectTitle => 'हम क्या रखते हैं';

  @override
  String get privacyCollectBody =>
      'साइन इन करने पर: साइन-इन से ईमेल और नाम, भाषा, सहेजे गए रास्ते, आपकी भेजी रिपोर्ट, खाता कब बना और आखिरी इस्तेमाल का दिन। बिना खाते के आपके बारे में हमारे सर्वर पर कुछ नहीं रखा जाता।';

  @override
  String get privacyNotCollectTitle => 'हम क्या कभी नहीं रखते';

  @override
  String get privacyNotCollectBody =>
      'आपका पासवर्ड (साइन-इन Google Firebase संभालता है), लोकेशन इतिहास, संपर्क या फ़ोन नंबर। कोई विज्ञापन नहीं, कोई ट्रैकिंग नहीं और हम डेटा कभी नहीं बेचते।';

  @override
  String get privacyLocationTitle => 'लोकेशन';

  @override
  String get privacyLocationBody =>
      'फ़ोन की लोकेशन सिर्फ़ \"मेरी लोकेशन\" दबाने पर पढ़ी जाती है और फ़ोन पर ही रहती है। साइन इन रहते हुए आखिरी हिस्से के लिए मंज़िल चुनने पर सड़क दूरी जानने के लिए स्टेशन और मंज़िल के बिंदु हमारे सर्वर को भेजे जाते हैं।';

  @override
  String get privacyReportsTitle => 'आपकी भेजी रिपोर्ट';

  @override
  String get privacyReportsBody =>
      'दूसरों को रिपोर्ट, उसकी जगह (लगभग 10 मीटर तक) और समय दिखता है, आपका नाम या खाता कभी नहीं। दुरुपयोग रोकने के लिए ही मॉडरेटर देख सकते हैं कि किस खाते ने रिपोर्ट भेजी। समय पूरा होने पर रिपोर्ट हट जाती है।';

  @override
  String get privacyRightsTitle => 'आपके विकल्प';

  @override
  String get privacyRightsBody =>
      'खाता हटाएं (प्रोफ़ाइल) आपका ईमेल, नाम और सहेजे रास्ते हटाता है और साइन-इन बंद करता है। आपकी भेजी रिपोर्ट दूसरे यात्रियों के लिए रहती हैं पर आपसे जुड़ी नहीं रहतीं। ऐप बिना खाते के भी चलता है।';

  @override
  String get privacyThirdPartyTitle => 'हम जिन सेवाओं पर निर्भर हैं';

  @override
  String get privacyThirdPartyBody =>
      'Google Firebase (साइन-इन) और Google Apps Script व Sheets (हमारा सर्वर और स्टोरेज); नक्शा लोड होने पर OpenStreetMap टाइल सर्वर; चालू हो तो सड़क दूरी के लिए openrouteservice; और बटन दबाने पर ही Uber, Ola या Rapido। जगह खोजते समय सिर्फ़ आपके लिखे शब्द Photon (OpenStreetMap डेटा) को भेजे जाते हैं।';

  @override
  String get searchAnyPlace => 'स्टेशन, इलाका या इमारत खोजें';

  @override
  String get stationLabel => 'स्टेशन';

  @override
  String get typeMoreToSearch =>
      'और जगहें खोजने के लिए कम से कम 3 अक्षर लिखें।';

  @override
  String get moreFromOsm => 'और जगहें (OpenStreetMap)';

  @override
  String get onlineSearchFailed =>
      'ऑनलाइन खोज नहीं हो पाई। इंटरनेट जाँचें या नक्शे पर जगह चुनें।';

  @override
  String get osmSearchCredit =>
      'जगह की खोज Photon के ज़रिए OpenStreetMap डेटा का इस्तेमाल करती है। सिर्फ़ आपके लिखे शब्द भेजे जाते हैं।';

  @override
  String get tripTitle => 'आपकी यात्रा';

  @override
  String get tripRoadOnlyClose =>
      'ये जगहें पास-पास हैं, इसलिए सड़क से जाना सबसे आसान है।';

  @override
  String get tripNoStationNear =>
      'इनमें से एक जगह के पास ऐप में अभी कोई स्टेशन नहीं है, इसलिए सिर्फ़ सड़क के विकल्प दिखाए गए हैं।';

  @override
  String get tripByRoad => 'सीधे सड़क से';

  @override
  String get tripByTrain => 'ट्रेन से';

  @override
  String minutesShort(int minutes) {
    return 'लगभग $minutes मिनट';
  }

  @override
  String tripLegToStation(String station) {
    return '$station स्टेशन तक पहुँचें';
  }

  @override
  String tripLegFromStation(String station, String place) {
    return '$station स्टेशन से $place';
  }

  @override
  String get autoStand => 'ऑटो स्टैंड';

  @override
  String get bookInApp => 'राइड बुक करें';

  @override
  String get bookInAppNote =>
      'ऐप खुलेगा; असली किराया और गाड़ी खाली है या नहीं, ऐप में दिखेगा।';

  @override
  String get departingNow => 'अभी छूट रही है';

  @override
  String get fareTrainTicketOnly => 'सिर्फ़ ट्रेन टिकट';

  @override
  String get noBusData => 'इस इलाके के बस स्टॉप अभी ऐप में नहीं हैं।';

  @override
  String get noLiveAutos =>
      'ऑटो की लाइव ट्रैकिंग कहीं उपलब्ध नहीं है, इसलिए ऐप वे स्टैंड दिखाता है जहाँ ऑटो आम तौर पर मिलते हैं, चलती गाड़ियाँ नहीं।';

  @override
  String get noLiveBuses =>
      'यहाँ की बसें लाइव लोकेशन नहीं देतीं, इसलिए ऐप स्टॉप और बसें कितनी देर में आती हैं वह दिखाता है, चलती बसें नहीं।';

  @override
  String get optionAuto => 'पूरा ऑटो से';

  @override
  String get optionBus => 'बस';

  @override
  String get optionCab => 'टैक्सी या कैब';

  @override
  String get optionTrain => 'ट्रेन';

  @override
  String get optionTrainAuto => 'ट्रेन + ऑटो';

  @override
  String get optionsTimeNote =>
      'समय अनुमान है, ट्रैफ़िक और इंतज़ार शामिल नहीं। किराया आधिकारिक मीटर दर से; असली किराया मीटर तय करता है।';

  @override
  String get scheduledNotLive =>
      'स्थिति समय-सारणी से है, लाइव GPS नहीं। ट्रेन देर से चल सकती है।';

  @override
  String get seeDetails => 'विवरण देखें';

  @override
  String get tagCheapest => 'सबसे सस्ता';

  @override
  String get tagEstimate => 'अनुमान';

  @override
  String get tagFastest => 'सबसे तेज़';

  @override
  String get tagScheduled => 'समय-सारणी';

  @override
  String get whereIsMyAuto => 'मेरा ऑटो कहाँ';

  @override
  String get whereIsMyBus => 'मेरी बस कहाँ';

  @override
  String get whereIsMyTrain => 'मेरी ट्रेन कहाँ';

  @override
  String get whereShort => 'देखें';

  @override
  String get youBoardHere => 'यहाँ चढ़ें';

  @override
  String get youGetOffHere => 'यहाँ उतरें';

  @override
  String farePlusTicket(int amount) {
    return '≈ ₹$amount + ट्रेन टिकट';
  }

  @override
  String inMinutes(int minutes) {
    return '$minutes मिनट में';
  }

  @override
  String minutesBig(int minutes) {
    return '$minutes मि.';
  }

  @override
  String reachesAt(String time) {
    return '$time पर पहुँचती है';
  }

  @override
  String standsNear(String place) {
    return '$place के पास ऑटो स्टैंड';
  }

  @override
  String stopsNear(String place) {
    return '$place के पास बस स्टॉप';
  }

  @override
  String stepAutoTo(String place) {
    return '$place तक ऑटो';
  }

  @override
  String stepWalkTo(String place) {
    return '$place तक पैदल';
  }

  @override
  String timetableComingFor(String from, String to) {
    return 'ट्रेन के समय अभी लोड नहीं हुए हैं। मध्य रेलवे की आधिकारिक समय-सारणी जुड़ते ही $from से $to की ट्रेनें यहाँ दिखेंगी, हर एक के साथ \"मेरी ट्रेन कहाँ\"।';
  }

  @override
  String trainArrivingNow(String station) {
    return '$station पर अभी आ रही है';
  }

  @override
  String trainAtNow(String station) {
    return 'अभी $station पर';
  }

  @override
  String trainFinished(String station) {
    return '$station पहुँच गई, सफ़र पूरा';
  }

  @override
  String trainLeftAgo(String station, int minutes) {
    return '$minutes मिनट पहले $station से निकली';
  }

  @override
  String trainNowAt(String station) {
    return 'अभी $station पर';
  }

  @override
  String trainNowBetween(String a, String b) {
    return '$a और $b के बीच';
  }

  @override
  String trainReached(String station) {
    return '$station पहुँच गई';
  }

  @override
  String trainReachesIn(String station, int minutes) {
    return '$minutes मिनट में $station पहुँचेगी';
  }

  @override
  String trainStartsAt(String station, String time) {
    return '$time पर $station से चलेगी';
  }

  @override
  String trainsBetween(String from, String to) {
    return 'ट्रेनें $from → $to';
  }

  @override
  String waysToGo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'जाने के $count तरीके',
      one: 'जाने का 1 तरीका',
    );
    return '$_temp0';
  }

  @override
  String get boardAtLabel => 'यहाँ से चढ़ें:';

  @override
  String get getOffAtLabel => 'यहाँ उतरें:';

  @override
  String trainComingFrom(String origin, String station, String time) {
    return '$origin से आ रही है; $time पर $station पहुँचेगी';
  }

  @override
  String timetableSourceNote(String date) {
    return 'समय मध्य रेलवे की आधिकारिक समय-सारणी से ($date से)। कुछ ट्रेनें बाद में बदली हैं, यात्रा से पहले स्टेशन का डिस्प्ले देखें।';
  }

  @override
  String get homeSubtitle => 'ट्रेन, ऑटो, बस और कैब एक ही जगह';

  @override
  String get trackTitle => 'अपनी सवारी देखें';

  @override
  String get whereIsMyCab => 'मेरी कैब कहाँ है';

  @override
  String get exploreTitle => 'देखें';

  @override
  String nextTrainsFrom(String station) {
    return '$station से अगली ट्रेनें';
  }

  @override
  String get change => 'बदलें';

  @override
  String get allTrains => 'सभी ट्रेनें';

  @override
  String get checkStationDisplay => 'यात्रा से पहले स्टेशन का डिस्प्ले देखें';

  @override
  String buildLabel(String number, String sha) {
    return 'बिल्ड $number · $sha';
  }

  @override
  String get buildLabelLocal => 'लोकल बिल्ड';

  @override
  String get whereIsMyCabTitle => 'मेरी कैब कहाँ है';

  @override
  String get liveCabsInApps =>
      'आपके पास की लाइव कारें और ऑटो सिर्फ़ Uber, Ola और Rapido ऐप में दिखते हैं। वहाँ देखने के लिए किसी पर टैप करें।';

  @override
  String get seeLiveInApp => 'ऐप में लाइव कारें देखें';

  @override
  String taxiStandsNear(String place) {
    return '$place के पास टैक्सी स्टैंड';
  }

  @override
  String get nearestFarAway => 'सबसे पास वाले, थोड़ी दूर';

  @override
  String get noTaxiStands => 'यहाँ पास अभी टैक्सी स्टैंड दर्ज नहीं हैं।';

  @override
  String kmAway(String km) {
    return '$km किमी दूर';
  }

  @override
  String fromPlace(String place) {
    return '$place से';
  }
}
