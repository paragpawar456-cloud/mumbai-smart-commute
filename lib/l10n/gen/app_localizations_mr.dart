// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'मुंबई स्मार्ट कम्यूट';

  @override
  String get navHome => 'होम';

  @override
  String get navRoutes => 'मार्ग';

  @override
  String get navMap => 'नकाशा';

  @override
  String get navSaved => 'जतन';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get homeGreeting => 'तुम्ही कुठे जात आहात?';

  @override
  String get fromLabel => 'कुठून';

  @override
  String get toLabel => 'कुठे';

  @override
  String get fromHint => 'सध्याचे ठिकाण किंवा स्टेशन';

  @override
  String get toHint => 'गंतव्य, उदा. योगीधाम, कल्याण पश्चिम';

  @override
  String get findRoutes => 'मार्ग शोधा';

  @override
  String get nearbyTransport => 'जवळची वाहतूक';

  @override
  String get nearbyTransportBody =>
      'तुमच्या जवळची स्टेशने, बस थांबे आणि रिक्षा स्टँड';

  @override
  String get savedJourneys => 'जतन केलेले प्रवास';

  @override
  String get noSavedJourneys =>
      'अजून कोणताही प्रवास जतन केलेला नाही. मार्ग शोधा आणि जतन करण्यासाठी तारा दाबा.';

  @override
  String get routesTitle => 'प्रवासाचे नियोजन';

  @override
  String get routesComingSoon =>
      'लोकल, मेट्रो आणि बसचे वेळापत्रक पुढील अपडेटमध्ये येईल.';

  @override
  String get mapTitle => 'नकाशा';

  @override
  String get mapComingSoon =>
      'नकाशा पुढील अपडेटमध्ये येईल. खरी लाइव्ह माहिती असेल तेव्हाच वाहने लाइव्ह दाखवली जातील.';

  @override
  String get savedTitle => 'जतन';

  @override
  String get profileTitle => 'प्रोफाइल';

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
  String get reducedMotion => 'अ‍ॅनिमेशन कमी करा';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get register => 'खाते तयार करा';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get displayName => 'नाव';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get resetEmailSent =>
      'त्या ईमेलचे खाते असल्यास, रीसेट लिंक पाठवली आहे.';

  @override
  String get verifyEmailSent => 'तुमच्या ईमेलवर पडताळणी लिंक पाठवली आहे.';

  @override
  String get continueWithGoogle => 'Google ने पुढे चला';

  @override
  String get continueAsGuest => 'खात्याशिवाय पुढे चला';

  @override
  String get guestNote =>
      'खात्याशिवायही वेळापत्रक आणि नकाशा वापरता येतो. मार्ग जतन करण्यासाठी आणि माहिती कळवण्यासाठी साइन इन करा.';

  @override
  String signedInAs(String email) {
    return '$email म्हणून साइन इन';
  }

  @override
  String get notSignedIn => 'साइन इन केलेले नाही';

  @override
  String get authUnavailable => 'या बिल्डमध्ये साइन-इन सुरू केलेले नाही.';

  @override
  String get deleteAccount => 'खाते हटवा';

  @override
  String get deleteAccountConfirm =>
      'यामुळे तुमचे खाते आणि जतन केलेली माहिती कायमची हटवली जाईल. पुढे जायचे?';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get confirm => 'पुष्टी करा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get offline => 'तुम्ही ऑफलाइन आहात. जतन केलेली माहिती दाखवत आहोत.';

  @override
  String get errorGeneric => 'काहीतरी चुकले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorNetwork => 'सर्व्हरशी संपर्क झाला नाही. तुमचे कनेक्शन तपासा.';

  @override
  String get backendStatus => 'सर्व्हर स्थिती';

  @override
  String get backendOk => 'जोडलेले';

  @override
  String get backendNotConfigured => 'या बिल्डमध्ये सर्व्हर सेट केलेला नाही';

  @override
  String get sourceLive => 'लाइव्ह';

  @override
  String get sourceScheduled => 'वेळापत्रकानुसार';

  @override
  String get sourceEstimate => 'अंदाज';

  @override
  String get sourceOfficial => 'अधिकृत';

  @override
  String get sourceCommunity => 'प्रवाशांनी कळवलेले';

  @override
  String get sourceUnknown => 'अज्ञात';

  @override
  String updatedAt(String time) {
    return '$time ला अपडेट';
  }

  @override
  String get about => 'माहिती आणि डेटा स्रोत';

  @override
  String get aboutBody =>
      'नकाशा डेटा © OpenStreetMap योगदानकर्ते. \'अंदाज\' असे लिहिलेले भाडे अधिकृत दरांवरून काढलेले आहे, ते लाइव्ह दर नाहीत. हे अ‍ॅप आपत्कालीन सेवा नाही.';

  @override
  String get selectStation => 'स्टेशन निवडा';

  @override
  String get searchStations => 'स्टेशन शोधा';

  @override
  String get noStationFound =>
      'स्टेशन सापडले नाही. दुसरे स्पेलिंग वापरून पाहा.';

  @override
  String get planJourney => 'प्रवास शोधा';

  @override
  String get noRouteFound => 'या स्टेशनांदरम्यान मार्ग सापडला नाही.';

  @override
  String get chooseBothStations => 'सुरुवातीचे आणि गंतव्य स्टेशन निवडा.';

  @override
  String rideLeg(String line) {
    return '$line';
  }

  @override
  String boardAt(String station) {
    return '$station येथे चढा';
  }

  @override
  String alightAt(String station) {
    return '$station येथे उतरा';
  }

  @override
  String stopsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count थांबे',
      one: '1 थांबा',
    );
    return '$_temp0';
  }

  @override
  String changesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बदल',
      one: '1 बदल',
      zero: 'थेट',
    );
    return '$_temp0';
  }

  @override
  String walkTo(String station, int minutes) {
    return '$station पर्यंत चाला (सुमारे $minutes मि.)';
  }

  @override
  String get timetableNotLoaded =>
      'वेळापत्रक अजून जोडलेले नाही. अधिकृत वेळापत्रक जोडल्यावर गाड्यांच्या वेळा दिसतील. आम्ही कधीही अंदाजे वेळा दाखवत नाही.';

  @override
  String nextTrain(String dep, String arr) {
    return 'पुढची गाडी $dep → पोहोचेल $arr';
  }

  @override
  String get noMoreTrainsToday =>
      'या प्रवासासाठी आज आणखी नियोजित गाड्या नाहीत.';

  @override
  String get departures => 'सुटणाऱ्या गाड्या';

  @override
  String towards(String station) {
    return '$station कडे';
  }

  @override
  String platformShort(String platform) {
    return 'फलाट $platform';
  }

  @override
  String get fastTrain => 'जलद';

  @override
  String get slowTrain => 'धीमी';

  @override
  String get acTrain => 'एसी';

  @override
  String get ladiesTrain => 'महिला';

  @override
  String get saveJourney => 'प्रवास जतन करा';

  @override
  String get removeJourney => 'जतन यादीतून काढा';

  @override
  String get recentSearches => 'अलीकडील शोध';

  @override
  String dataVersion(int version, String origin) {
    return 'डेटा आवृत्ती $version · $origin';
  }

  @override
  String get originBundled => 'अ‍ॅपमध्ये समाविष्ट';

  @override
  String get originCached => 'आधी डाउनलोड केलेले';

  @override
  String get originServer => 'आत्ताच अपडेट केलेले';

  @override
  String get showOnMap => 'नकाशावर दाखवा';

  @override
  String get myLocation => 'माझे ठिकाण';

  @override
  String get layers => 'स्तर';

  @override
  String get layerSuburban => 'लोकल';

  @override
  String get layerMetro => 'मेट्रो';

  @override
  String get locationDenied =>
      'लोकेशन परवानगी बंद आहे. नकाशा तरीही चालेल; तुमचे ठिकाण पाहण्यासाठी सेटिंग्जमध्ये चालू करा.';

  @override
  String get locationServiceOff => 'या फोनवर लोकेशन बंद आहे.';

  @override
  String get lineGeometryNote =>
      'मार्ग स्टेशनांदरम्यान सरळ रेषेत दाखवले आहेत, अचूक रुळांवर नाहीत.';

  @override
  String get linesAtStation => 'मार्ग';

  @override
  String get lastMileTitle => 'स्टेशन ते घरापर्यंत';

  @override
  String get lastMileHomeBody =>
      'स्टेशनपासून तुमच्या ठिकाणापर्यंत चालत, रिक्षा, शेअर रिक्षा, बस किंवा कॅब';

  @override
  String get lastMileFromStation => 'स्टेशनपासून';

  @override
  String get lastMileTo => 'कुठे जायचे';

  @override
  String get lastMileToHint => 'ठिकाण शोधा किंवा नकाशावर निवडा';

  @override
  String get lastMilePickOnMap => 'नकाशावर निवडा';

  @override
  String get lastMileUseThisPoint => 'हे ठिकाण वापरा';

  @override
  String get lastMileDroppedPin => 'नकाशावरील ठिकाण';

  @override
  String get lastMileChooseDestination =>
      'पर्याय पाहण्यासाठी तुम्ही कुठे जात आहात ते निवडा.';

  @override
  String get lastMileFromHere => 'इथून पुढचा प्रवास';

  @override
  String get searchPlaces => 'ठिकाणे शोधा';

  @override
  String get noPlaceFound => 'असे ठिकाण अजून नाही. नकाशावर ठिकाण निवडून पाहा.';

  @override
  String get sortCheapest => 'स्वस्त';

  @override
  String get sortFastest => 'जलद';

  @override
  String get sortLeastWalking => 'कमी चालणे';

  @override
  String distanceStraight(String km) {
    return 'सरळ रेषेत $km किमी';
  }

  @override
  String distanceRoadEstimate(String km) {
    return 'रस्त्याने सुमारे $km किमी (अंदाज)';
  }

  @override
  String distanceRoad(String km) {
    return 'रस्त्याने $km किमी';
  }

  @override
  String get optWalk => 'चालत';

  @override
  String get optAutoMeter => 'रिक्षा (मीटरने)';

  @override
  String get optTaxiMeter => 'काळी-पिवळी टॅक्सी (मीटरने)';

  @override
  String get optSharedAuto => 'शेअर रिक्षा';

  @override
  String optBus(String operator, String number) {
    return '$operator बस $number';
  }

  @override
  String fareFrom(int amount) {
    return '₹$amount पासून';
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
  String get fareUnknown => 'भाडे माहीत नाही';

  @override
  String get fareInApp => 'किंमत त्यांच्या ॲपमध्ये';

  @override
  String minutesAbout(int minutes) {
    return 'वाहतूक नसताना सुमारे $minutes मिनिटे';
  }

  @override
  String walkMeters(int meters) {
    return '$meters मी चालणे';
  }

  @override
  String get nightFareApplied => 'रात्रीचे जादा भाडे धरले आहे';

  @override
  String nearestStand(String name, int meters) {
    return 'जवळचा स्टँड: $name, $meters मी';
  }

  @override
  String get noStandKnown => 'स्टेशनजवळ अजून स्टँड नोंदवलेला नाही';

  @override
  String busBoardAlight(String board, String alight) {
    return '$board येथे चढा, $alight येथे उतरा';
  }

  @override
  String get availabilityUnknown =>
      'आत्ता वाहन उपलब्ध आहे का ते आम्हाला दिसत नाही.';

  @override
  String openApp(String name) {
    return '$name उघडा';
  }

  @override
  String get couldNotOpen => 'ॲप उघडता आले नाही.';

  @override
  String get howWeEstimate => 'हे आकडे कसे काढले';

  @override
  String get assumptionsBody =>
      'रस्त्याचा मार्ग उपलब्ध नसल्यास अंतर = सरळ रेषा × 1.3. वेळ: चालणे 4.5 किमी/तास, रिक्षा 18 किमी/तास, टॅक्सी 20 किमी/तास; वाहतूक किंवा प्रतीक्षा धरलेली नाही. मीटर भाडे प्रकाशित दराने काढले आहे; खरे भाडे मीटर ठरवतो.';

  @override
  String fareRuleSource(String mode, String source, String date) {
    return '$mode: दर $source, $date पासून लागू';
  }

  @override
  String get noFareRules =>
      'भाडेदर अजून भरलेले नाहीत, त्यामुळे मीटर भाड्याचा अंदाज देता येत नाही.';

  @override
  String get nearbyPickups => 'स्टेशनजवळचे स्टँड';

  @override
  String get nearbyPickupsEmpty => 'या स्टेशनजवळ अजून स्टँड नोंदवलेले नाहीत.';

  @override
  String get verificationAdmin => 'आम्ही तपासलेले';

  @override
  String get verificationOsm => 'OpenStreetMap वरून';

  @override
  String get verificationCommunity => 'प्रवाशांनी कळवलेले';

  @override
  String get communityReports => 'प्रवाशांच्या सूचना';

  @override
  String get communityReportsEmpty => 'या स्टेशनजवळ सध्या कोणतीही सूचना नाही.';

  @override
  String get communityReportsOffline =>
      'सूचनांसाठी सर्व्हर लागतो, तो अजून सेट केलेला नाही.';

  @override
  String get reportSomething => 'कळवा';

  @override
  String get reportWhere => 'कुठे';

  @override
  String get reportTypeQueue => 'लांब रांग';

  @override
  String get reportTypeNoVehicles => 'रिक्षा/टॅक्सी नाहीत';

  @override
  String get reportTypeStandMoved => 'स्टँड हलवला आहे';

  @override
  String get reportTypeStopIssue => 'बस थांब्याची अडचण';

  @override
  String get reportTypeClosure => 'रस्ता बंद';

  @override
  String get reportTypeDisruption => 'व्यत्यय';

  @override
  String get reportNoteHint => 'छोटी टीप (ऐच्छिक)';

  @override
  String get reportPrivacy =>
      'इतरांना सूचना आणि ठिकाण दिसते, तुमचे नाव किंवा खाते कधीच नाही.';

  @override
  String get reportSubmit => 'सूचना पाठवा';

  @override
  String get reportSent => 'धन्यवाद. सूचना कालबाह्य होईपर्यंत इतरांना दिसेल.';

  @override
  String get reportConfirm => 'अजूनही खरे';

  @override
  String reportConfirmed(int count) {
    return '$count जणांनी पुष्टी केली';
  }

  @override
  String reportAgo(int minutes) {
    return '$minutes मिनिटांपूर्वी';
  }
}
