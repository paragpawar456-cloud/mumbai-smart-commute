import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mumbai Smart Commute'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get navRoutes;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Live Map'**
  String get navMap;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get homeGreeting;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @fromHint.
  ///
  /// In en, this message translates to:
  /// **'Current location or station'**
  String get fromHint;

  /// No description provided for @toHint.
  ///
  /// In en, this message translates to:
  /// **'Destination, e.g. Yogidham, Kalyan West'**
  String get toHint;

  /// No description provided for @findRoutes.
  ///
  /// In en, this message translates to:
  /// **'Find routes'**
  String get findRoutes;

  /// No description provided for @nearbyTransport.
  ///
  /// In en, this message translates to:
  /// **'Nearby transport'**
  String get nearbyTransport;

  /// No description provided for @nearbyTransportBody.
  ///
  /// In en, this message translates to:
  /// **'Stations, bus stops and auto stands near you'**
  String get nearbyTransportBody;

  /// No description provided for @savedJourneys.
  ///
  /// In en, this message translates to:
  /// **'Saved journeys'**
  String get savedJourneys;

  /// No description provided for @noSavedJourneys.
  ///
  /// In en, this message translates to:
  /// **'No saved journeys yet. Search a route and tap the star to save it.'**
  String get noSavedJourneys;

  /// No description provided for @routesTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a journey'**
  String get routesTitle;

  /// No description provided for @routesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Train, metro and bus timetables arrive in the next update.'**
  String get routesComingSoon;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The map arrives in the next update. Vehicles are only shown as live when a genuine live feed exists.'**
  String get mapComingSoon;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @reducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reducedMotion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link has been sent.'**
  String get resetEmailSent;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email.'**
  String get verifyEmailSent;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get continueAsGuest;

  /// No description provided for @guestNote.
  ///
  /// In en, this message translates to:
  /// **'You can use timetables and the map without an account. Sign in to save routes and report updates.'**
  String get guestNote;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in is not configured in this build.'**
  String get authUnavailable;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and saved data. Continue?'**
  String get deleteAccountConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing saved information.'**
  String get offline;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @backendStatus.
  ///
  /// In en, this message translates to:
  /// **'Server status'**
  String get backendStatus;

  /// No description provided for @backendOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get backendOk;

  /// No description provided for @backendNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server not configured in this build'**
  String get backendNotConfigured;

  /// No description provided for @sourceLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get sourceLive;

  /// No description provided for @sourceScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get sourceScheduled;

  /// No description provided for @sourceEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate'**
  String get sourceEstimate;

  /// No description provided for @sourceOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get sourceOfficial;

  /// No description provided for @sourceCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community reported'**
  String get sourceCommunity;

  /// No description provided for @sourceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sourceUnknown;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About and data sources'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors. Fares marked Estimate are calculated from official tariffs and are not live quotes. This app is not an emergency service.'**
  String get aboutBody;

  /// No description provided for @selectStation.
  ///
  /// In en, this message translates to:
  /// **'Select station'**
  String get selectStation;

  /// No description provided for @searchStations.
  ///
  /// In en, this message translates to:
  /// **'Search stations'**
  String get searchStations;

  /// No description provided for @noStationFound.
  ///
  /// In en, this message translates to:
  /// **'No station found. Try another spelling.'**
  String get noStationFound;

  /// No description provided for @planJourney.
  ///
  /// In en, this message translates to:
  /// **'Plan journey'**
  String get planJourney;

  /// No description provided for @noRouteFound.
  ///
  /// In en, this message translates to:
  /// **'No route found between these stations.'**
  String get noRouteFound;

  /// No description provided for @chooseBothStations.
  ///
  /// In en, this message translates to:
  /// **'Choose a start and destination station.'**
  String get chooseBothStations;

  /// No description provided for @rideLeg.
  ///
  /// In en, this message translates to:
  /// **'{line}'**
  String rideLeg(String line);

  /// No description provided for @boardAt.
  ///
  /// In en, this message translates to:
  /// **'Board at {station}'**
  String boardAt(String station);

  /// No description provided for @alightAt.
  ///
  /// In en, this message translates to:
  /// **'Get off at {station}'**
  String alightAt(String station);

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stop} other{{count} stops}}'**
  String stopsCount(int count);

  /// No description provided for @changesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Direct} =1{1 change} other{{count} changes}}'**
  String changesCount(int count);

  /// No description provided for @walkTo.
  ///
  /// In en, this message translates to:
  /// **'Walk to {station} (about {minutes} min)'**
  String walkTo(String station, int minutes);

  /// No description provided for @timetableNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Timetable not loaded yet. Train times will appear once the official timetable is added. We never guess train times.'**
  String get timetableNotLoaded;

  /// No description provided for @nextTrain.
  ///
  /// In en, this message translates to:
  /// **'Next train {dep} → arrives {arr}'**
  String nextTrain(String dep, String arr);

  /// No description provided for @noMoreTrainsToday.
  ///
  /// In en, this message translates to:
  /// **'No more scheduled trains today for this journey.'**
  String get noMoreTrainsToday;

  /// No description provided for @departures.
  ///
  /// In en, this message translates to:
  /// **'Departures'**
  String get departures;

  /// No description provided for @towards.
  ///
  /// In en, this message translates to:
  /// **'to {station}'**
  String towards(String station);

  /// No description provided for @platformShort.
  ///
  /// In en, this message translates to:
  /// **'PF {platform}'**
  String platformShort(String platform);

  /// No description provided for @fastTrain.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fastTrain;

  /// No description provided for @slowTrain.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slowTrain;

  /// No description provided for @acTrain.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get acTrain;

  /// No description provided for @ladiesTrain.
  ///
  /// In en, this message translates to:
  /// **'Ladies'**
  String get ladiesTrain;

  /// No description provided for @saveJourney.
  ///
  /// In en, this message translates to:
  /// **'Save journey'**
  String get saveJourney;

  /// No description provided for @removeJourney.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeJourney;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @dataVersion.
  ///
  /// In en, this message translates to:
  /// **'Data version {version} · {origin}'**
  String dataVersion(int version, String origin);

  /// No description provided for @originBundled.
  ///
  /// In en, this message translates to:
  /// **'built into the app'**
  String get originBundled;

  /// No description provided for @originCached.
  ///
  /// In en, this message translates to:
  /// **'downloaded earlier'**
  String get originCached;

  /// No description provided for @originServer.
  ///
  /// In en, this message translates to:
  /// **'just updated'**
  String get originServer;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @layers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// No description provided for @layerSuburban.
  ///
  /// In en, this message translates to:
  /// **'Local trains'**
  String get layerSuburban;

  /// No description provided for @layerMetro.
  ///
  /// In en, this message translates to:
  /// **'Metro'**
  String get layerMetro;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off. The map still works; turn it on in settings to see where you are.'**
  String get locationDenied;

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone.'**
  String get locationServiceOff;

  /// No description provided for @lineGeometryNote.
  ///
  /// In en, this message translates to:
  /// **'Lines are drawn straight between stations, not along the exact track.'**
  String get lineGeometryNote;

  /// No description provided for @linesAtStation.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get linesAtStation;

  /// No description provided for @lastMileTitle.
  ///
  /// In en, this message translates to:
  /// **'Station to doorstep'**
  String get lastMileTitle;

  /// No description provided for @lastMileHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Walk, auto, shared auto, bus or cab from the station to where you are going'**
  String get lastMileHomeBody;

  /// No description provided for @lastMileFromStation.
  ///
  /// In en, this message translates to:
  /// **'From station'**
  String get lastMileFromStation;

  /// No description provided for @lastMileTo.
  ///
  /// In en, this message translates to:
  /// **'Going to'**
  String get lastMileTo;

  /// No description provided for @lastMileToHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place or pick on the map'**
  String get lastMileToHint;

  /// No description provided for @lastMilePickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on the map'**
  String get lastMilePickOnMap;

  /// No description provided for @lastMileUseThisPoint.
  ///
  /// In en, this message translates to:
  /// **'Use this point'**
  String get lastMileUseThisPoint;

  /// No description provided for @lastMileDroppedPin.
  ///
  /// In en, this message translates to:
  /// **'Point on the map'**
  String get lastMileDroppedPin;

  /// No description provided for @lastMileChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose where you are going to see your options.'**
  String get lastMileChooseDestination;

  /// No description provided for @lastMileFromHere.
  ///
  /// In en, this message translates to:
  /// **'Last mile from here'**
  String get lastMileFromHere;

  /// No description provided for @searchPlaces.
  ///
  /// In en, this message translates to:
  /// **'Search places'**
  String get searchPlaces;

  /// No description provided for @noPlaceFound.
  ///
  /// In en, this message translates to:
  /// **'No matching place yet. Try picking the point on the map.'**
  String get noPlaceFound;

  /// No description provided for @sortCheapest.
  ///
  /// In en, this message translates to:
  /// **'Cheapest'**
  String get sortCheapest;

  /// No description provided for @sortFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get sortFastest;

  /// No description provided for @sortLeastWalking.
  ///
  /// In en, this message translates to:
  /// **'Least walking'**
  String get sortLeastWalking;

  /// No description provided for @distanceStraight.
  ///
  /// In en, this message translates to:
  /// **'{km} km in a straight line'**
  String distanceStraight(String km);

  /// No description provided for @distanceRoadEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {km} km by road (estimated)'**
  String distanceRoadEstimate(String km);

  /// No description provided for @distanceRoad.
  ///
  /// In en, this message translates to:
  /// **'{km} km by road'**
  String distanceRoad(String km);

  /// No description provided for @optWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get optWalk;

  /// No description provided for @optAutoMeter.
  ///
  /// In en, this message translates to:
  /// **'Auto (by meter)'**
  String get optAutoMeter;

  /// No description provided for @optTaxiMeter.
  ///
  /// In en, this message translates to:
  /// **'Kaali-peeli taxi (by meter)'**
  String get optTaxiMeter;

  /// No description provided for @optSharedAuto.
  ///
  /// In en, this message translates to:
  /// **'Shared auto'**
  String get optSharedAuto;

  /// No description provided for @optBus.
  ///
  /// In en, this message translates to:
  /// **'{operator} bus {number}'**
  String optBus(String operator, String number);

  /// No description provided for @fareFrom.
  ///
  /// In en, this message translates to:
  /// **'from ₹{amount}'**
  String fareFrom(int amount);

  /// No description provided for @fareAbout.
  ///
  /// In en, this message translates to:
  /// **'≈ ₹{amount}'**
  String fareAbout(int amount);

  /// No description provided for @fareShared.
  ///
  /// In en, this message translates to:
  /// **'₹{amount} per seat'**
  String fareShared(int amount);

  /// No description provided for @fareUnknown.
  ///
  /// In en, this message translates to:
  /// **'Fare not known'**
  String get fareUnknown;

  /// No description provided for @fareInApp.
  ///
  /// In en, this message translates to:
  /// **'Price in their app'**
  String get fareInApp;

  /// No description provided for @minutesAbout.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min without traffic'**
  String minutesAbout(int minutes);

  /// No description provided for @walkMeters.
  ///
  /// In en, this message translates to:
  /// **'{meters} m walk'**
  String walkMeters(int meters);

  /// No description provided for @nightFareApplied.
  ///
  /// In en, this message translates to:
  /// **'Includes the night charge'**
  String get nightFareApplied;

  /// No description provided for @nearestStand.
  ///
  /// In en, this message translates to:
  /// **'Nearest stand: {name}, {meters} m'**
  String nearestStand(String name, int meters);

  /// No description provided for @noStandKnown.
  ///
  /// In en, this message translates to:
  /// **'No stand mapped near the station yet'**
  String get noStandKnown;

  /// No description provided for @busBoardAlight.
  ///
  /// In en, this message translates to:
  /// **'Board at {board}, get off at {alight}'**
  String busBoardAlight(String board, String alight);

  /// No description provided for @availabilityUnknown.
  ///
  /// In en, this message translates to:
  /// **'We cannot see whether a vehicle is there right now.'**
  String get availabilityUnknown;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String openApp(String name);

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open the app.'**
  String get couldNotOpen;

  /// No description provided for @howWeEstimate.
  ///
  /// In en, this message translates to:
  /// **'How these numbers are worked out'**
  String get howWeEstimate;

  /// No description provided for @assumptionsBody.
  ///
  /// In en, this message translates to:
  /// **'Road distance is the straight line × 1.3 unless a road route is available. Times assume walking at 4.5 km/h, autos at 18 km/h and taxis at 20 km/h, with no traffic or waiting. Meter fares use the published rate; the meter decides the real fare.'**
  String get assumptionsBody;

  /// No description provided for @fareRuleSource.
  ///
  /// In en, this message translates to:
  /// **'{mode}: rates from {source}, effective {date}'**
  String fareRuleSource(String mode, String source, String date);

  /// No description provided for @noFareRules.
  ///
  /// In en, this message translates to:
  /// **'No fare rates entered yet, so meter fares cannot be estimated.'**
  String get noFareRules;

  /// No description provided for @nearbyPickups.
  ///
  /// In en, this message translates to:
  /// **'Stands near the station'**
  String get nearbyPickups;

  /// No description provided for @nearbyPickupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stands recorded near this station yet.'**
  String get nearbyPickupsEmpty;

  /// No description provided for @verificationAdmin.
  ///
  /// In en, this message translates to:
  /// **'Checked by us'**
  String get verificationAdmin;

  /// No description provided for @verificationOsm.
  ///
  /// In en, this message translates to:
  /// **'From OpenStreetMap'**
  String get verificationOsm;

  /// No description provided for @verificationCommunity.
  ///
  /// In en, this message translates to:
  /// **'Reported by commuters'**
  String get verificationCommunity;

  /// No description provided for @communityReports.
  ///
  /// In en, this message translates to:
  /// **'Commuter reports'**
  String get communityReports;

  /// No description provided for @communityReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports near this station right now.'**
  String get communityReportsEmpty;

  /// No description provided for @communityReportsOffline.
  ///
  /// In en, this message translates to:
  /// **'Reports need the server, which is not set up yet.'**
  String get communityReportsOffline;

  /// No description provided for @reportSomething.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportSomething;

  /// No description provided for @reportWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get reportWhere;

  /// No description provided for @reportTypeQueue.
  ///
  /// In en, this message translates to:
  /// **'Long queue'**
  String get reportTypeQueue;

  /// No description provided for @reportTypeNoVehicles.
  ///
  /// In en, this message translates to:
  /// **'No autos or taxis'**
  String get reportTypeNoVehicles;

  /// No description provided for @reportTypeStandMoved.
  ///
  /// In en, this message translates to:
  /// **'Stand has moved'**
  String get reportTypeStandMoved;

  /// No description provided for @reportTypeStopIssue.
  ///
  /// In en, this message translates to:
  /// **'Bus stop problem'**
  String get reportTypeStopIssue;

  /// No description provided for @reportTypeClosure.
  ///
  /// In en, this message translates to:
  /// **'Road closed'**
  String get reportTypeClosure;

  /// No description provided for @reportTypeDisruption.
  ///
  /// In en, this message translates to:
  /// **'Disruption'**
  String get reportTypeDisruption;

  /// No description provided for @reportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Short note (optional)'**
  String get reportNoteHint;

  /// No description provided for @reportPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Others see the report and its place, never your name or account.'**
  String get reportPrivacy;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get reportSubmit;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks. Others will see your report until it expires.'**
  String get reportSent;

  /// No description provided for @reportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Still true'**
  String get reportConfirm;

  /// No description provided for @reportConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by {count}'**
  String reportConfirmed(int count);

  /// No description provided for @reportAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String reportAgo(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
