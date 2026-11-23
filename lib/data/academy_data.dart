import 'package:cloud_firestore/cloud_firestore.dart';

class AssetImages {
  static const String hero = 'assets/images/hero_craftbridge_trade.jpg';
  static const String academy = 'assets/images/academy_practical_training.jpg';
  static const String electrician =
      'assets/images/provider_portrait_electrician.jpg';
  static const String plumber = 'assets/images/provider_portrait_plumber.jpg';
  static const String hvac = 'assets/images/provider_portrait_hvac.jpg';
  static const String cleaning =
      'assets/images/provider_portrait_cleaning.jpg';

  static String forTrade(String trade) {
    switch (trade) {
      case 'Plumbing':
        return plumber;
      case 'Appliance Repair':
        return hvac;
      case 'Cleaning':
        return cleaning;
      case 'Electrical':
      default:
        return electrician;
    }
  }
}

class TradeCategoryMeta {
  final String trade;
  final String displayTitle;
  final String priceFrom;
  final String avgEta;
  final String sampleTitle;
  final String sampleDescription;
  final double defaultMin;
  final double defaultMax;

  const TradeCategoryMeta({
    required this.trade,
    required this.displayTitle,
    required this.priceFrom,
    required this.avgEta,
    required this.sampleTitle,
    required this.sampleDescription,
    required this.defaultMin,
    required this.defaultMax,
  });
}

const List<TradeCategoryMeta> tradeCategories = [
  TradeCategoryMeta(
    trade: 'Electrical',
    displayTitle: 'Electrical Services',
    priceFrom: 'From \$35',
    avgEta: 'Avg ETA 24 mins',
    sampleTitle: 'MCB & Breaker Panel Fault',
    sampleDescription:
        'Main distribution board 32A MCB trips repeatedly whenever induction cooktop and water heater run together.',
    defaultMin: 45,
    defaultMax: 110,
  ),
  TradeCategoryMeta(
    trade: 'Plumbing',
    displayTitle: 'Plumbing Services',
    priceFrom: 'From \$40',
    avgEta: 'Avg ETA 28 mins',
    sampleTitle: 'Under-Sink Brass Valve Leak',
    sampleDescription:
        'Continuous hot-water drip at the braided shutoff valve under the kitchen sink. Requires seal replacement.',
    defaultMin: 40,
    defaultMax: 95,
  ),
  TradeCategoryMeta(
    trade: 'Appliance Repair',
    displayTitle: 'Appliance Repair',
    priceFrom: 'From \$45',
    avgEta: 'Avg ETA 32 mins',
    sampleTitle: 'Washing Machine E24 Drain Fault',
    sampleDescription:
        'Front-load washing machine stops mid-rinse with water trapped in drum and flashes E24 drain pump error code.',
    defaultMin: 50,
    defaultMax: 125,
  ),
  TradeCategoryMeta(
    trade: 'Cleaning',
    displayTitle: 'Cleaning Services',
    priceFrom: 'From \$30',
    avgEta: 'Avg ETA 35 mins',
    sampleTitle: 'Full 2BHK Kitchen & Bathroom Steam Deep Cleaning',
    sampleDescription:
        'Move-in deep sanitization required for kitchen exhaust hood, tile grout, and two bathrooms.',
    defaultMin: 45,
    defaultMax: 110,
  ),
];

class AcademyDataSeeder {
  static Future<bool> seedInitialAcademyRegistry(
    FirebaseFirestore db,
    String adminEmail,
  ) async {
    final existing = await db.collection('providers').limit(1).get();
    if (existing.docs.isNotEmpty) {
      return false;
    }

    final batch = db.batch();

    final graduates = [
      {
        'id': 'prov_marcus_el',
        'displayName': 'Marcus Thomas',
        'avatarUrl': AssetImages.electrician,
        'trade': 'Electrical',
        'trainingDays': 28,
        'certificateId': 'SOFTI-2026-EL-104',
        'trainingCenter': 'East Metro Practical Trade Campus',
        'practicalScore': 94,
        'hourlyRate': 38,
        'completedJobs': 47,
        'rating': 4.9,
        'zoneName': 'Indiranagar Central',
        'lat': 12.9784,
        'lng': 77.6408,
        'bio':
            '28-day certified electrician handling residential breaker panels, GFCI earthing audits, and home EV line wiring within 15 km.',
        'issuedDate': '2026-09-14',
        'modulesCompleted': [
          'Panel Load Balancing',
          'GFCI & Earthing Audit',
          'EV Line Termination'
        ],
      },
      {
        'id': 'prov_arthur_pl',
        'displayName': 'Arthur Pendelton',
        'avatarUrl': AssetImages.plumber,
        'trade': 'Plumbing',
        'trainingDays': 30,
        'certificateId': 'SOFTI-2026-PL-208',
        'trainingCenter': 'Central Guild Workshop',
        'practicalScore': 96,
        'hourlyRate': 35,
        'completedJobs': 63,
        'rating': 5.0,
        'zoneName': 'Koramangala 4th Block',
        'lat': 12.9352,
        'lng': 77.6245,
        'bio':
            '30-day intensive practical plumber specializing in concealed leak detection, booster pumps, and copper/PEX manifold retrofits.',
        'issuedDate': '2026-08-29',
        'modulesCompleted': [
          'Hydrostatic Leak Tracing',
          'Copper Brazing & PEX',
          'Pump Pressure Calibration'
        ],
      },
      {
        'id': 'prov_devon_ap',
        'displayName': 'Devon Morales',
        'avatarUrl': AssetImages.hvac,
        'trade': 'Appliance Repair',
        'trainingDays': 24,
        'certificateId': 'SOFTI-2026-AP-312',
        'trainingCenter': 'South Corridor Skills Lab',
        'practicalScore': 92,
        'hourlyRate': 40,
        'completedJobs': 41,
        'rating': 4.8,
        'zoneName': 'MG Road / Shivajinagar',
        'lat': 12.9756,
        'lng': 77.6066,
        'bio':
            '24-day certified technician repairing inverter washers, refrigerators, induction cooktops, and split AC units.',
        'issuedDate': '2026-10-03',
        'modulesCompleted': [
          'BLDC Motor Diagnostics',
          'Inverter PCB Testing',
          'Thermal & Seal Safety'
        ],
      },
      {
        'id': 'prov_sarah_cl',
        'displayName': 'Sarah Jenkins',
        'avatarUrl': AssetImages.cleaning,
        'trade': 'Cleaning',
        'trainingDays': 18,
        'certificateId': 'SOFTI-2026-CL-419',
        'trainingCenter': 'East Metro Practical Trade Campus',
        'practicalScore': 95,
        'hourlyRate': 28,
        'completedJobs': 58,
        'rating': 4.9,
        'zoneName': 'Whitefield ITPL',
        'lat': 12.9855,
        'lng': 77.7363,
        'bio':
            '18-day certified deep-cleaning and home sanitization specialist equipped with HEPA extraction and non-toxic steam tools.',
        'issuedDate': '2026-10-18',
        'modulesCompleted': [
          'Steam Sanitization',
          'Kitchen Degreasing',
          'Upholstery Extraction'
        ],
      },
      {
        'id': 'prov_karthik_el',
        'displayName': 'Karthik Rao',
        'avatarUrl': AssetImages.academy,
        'trade': 'Appliance Repair',
        'trainingDays': 21,
        'certificateId': 'SOFTI-2026-AP-522',
        'trainingCenter': 'South Corridor Skills Lab',
        'practicalScore': 89,
        'hourlyRate': 32,
        'completedJobs': 52,
        'rating': 4.8,
        'zoneName': 'HSR Layout Sector 2',
        'lat': 12.9121,
        'lng': 77.6446,
        'bio':
            '21-day practical graduate servicing dishwashers, microwaves, and front-load laundry equipment across South Metro.',
        'issuedDate': '2026-09-25',
        'modulesCompleted': [
          'Drain Pump Overhaul',
          'Heating Element Testing',
          'Control Board Diagnostics'
        ],
      },
    ];

    for (final grad in graduates) {
      final id = grad['id'] as String;
      final certId = grad['certificateId'] as String;

      batch.set(db.collection('providers').doc(id), {
        'uid': id,
        'displayName': grad['displayName'],
        'avatarUrl': grad['avatarUrl'],
        'trade': grad['trade'],
        'trainingDays': grad['trainingDays'],
        'certificateId': certId,
        'trainingCenter': grad['trainingCenter'],
        'practicalScore': grad['practicalScore'],
        'verificationStatus': 'verified',
        'isAvailable': true,
        'hourlyRate': grad['hourlyRate'],
        'completedJobs': grad['completedJobs'],
        'rating': grad['rating'],
        'zoneName': grad['zoneName'],
        'lat': grad['lat'],
        'lng': grad['lng'],
        'bio': grad['bio'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(db.collection('certificates').doc(certId), {
        'certId': certId,
        'providerId': id,
        'holderName': grad['displayName'],
        'trade': grad['trade'],
        'trainingDays': grad['trainingDays'],
        'practicalScore': grad['practicalScore'],
        'centerName': grad['trainingCenter'],
        'modulesCompleted': grad['modulesCompleted'],
        'status': 'verified',
        'issuedDate': grad['issuedDate'],
        'verifiedBy': adminEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final sampleRequests = [
      {
        'id': 'req_softi_indiranagar_el',
        'clientId': 'sample_client_east',
        'clientName': 'Rohan Deshmukh',
        'title': 'Main Distribution Box Breaker Tripping Under Load',
        'description':
            '32A RCCB trips whenever the kitchen induction and water heater run simultaneously.',
        'trade': 'Electrical',
        'urgency': 'same_day',
        'zoneName': 'Indiranagar Central',
        'lat': 12.9784,
        'lng': 77.6408,
        'maxRadiusKm': 12,
        'budgetMin': 50,
        'budgetMax': 85,
        'estimatedBudget': 68,
        'photos': [AssetImages.hero],
        'contactPreview': '+91 ••••• 4821 · 100ft Road, Indiranagar',
        'contactPhone': '+91 98450 14821',
        'contactAddress': '42, 12th Main, 100ft Road, Indiranagar Central',
        'preferredWindow': 'Today 2:00 PM – 5:00 PM',
      },
      {
        'id': 'req_softi_koramangala_pl',
        'clientId': 'sample_client_south',
        'clientName': 'Meera Iyer',
        'title': 'Under-Sink Pressure Valve Leak & Pipe Seal',
        'description':
            'Slow drip at the braided hot-water shutoff valve behind kitchen cabinet.',
        'trade': 'Plumbing',
        'urgency': 'standard',
        'zoneName': 'Koramangala 4th Block',
        'lat': 12.9352,
        'lng': 77.6245,
        'maxRadiusKm': 15,
        'budgetMin': 35,
        'budgetMax': 65,
        'estimatedBudget': 50,
        'photos': [AssetImages.academy],
        'contactPreview': '+91 ••••• 7310 · 4th Block, Koramangala',
        'contactPhone': '+91 98801 27310',
        'contactAddress': '18, 8th Cross, Koramangala 4th Block',
        'preferredWindow': 'Tomorrow 10:00 AM – 1:00 PM',
      },
    ];

    for (final reqItem in sampleRequests) {
      final reqId = reqItem['id'] as String;
      final reqRef = db.collection('serviceRequests').doc(reqId);
      batch.set(reqRef, {
        'clientId': reqItem['clientId'],
        'clientName': reqItem['clientName'],
        'providerId': '',
        'providerName': '',
        'title': reqItem['title'],
        'description': reqItem['description'],
        'trade': reqItem['trade'],
        'urgency': reqItem['urgency'],
        'zoneName': reqItem['zoneName'],
        'lat': reqItem['lat'],
        'lng': reqItem['lng'],
        'maxRadiusKm': reqItem['maxRadiusKm'],
        'budgetMin': reqItem['budgetMin'],
        'budgetMax': reqItem['budgetMax'],
        'estimatedBudget': reqItem['estimatedBudget'],
        'photos': reqItem['photos'],
        'contactPreview': reqItem['contactPreview'],
        'status': 'open',
        'paymentStatus': 'unpaid',
        'paymentTxnId': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(reqRef.collection('contactDetails').doc('private'), {
        'requestId': reqId,
        'clientId': reqItem['clientId'],
        'contactPhone': reqItem['contactPhone'],
        'contactAddress': reqItem['contactAddress'],
        'preferredWindow': reqItem['preferredWindow'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    return true;
  }
}
