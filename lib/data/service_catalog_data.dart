import 'package:flutter/material.dart';

class ServiceSubItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ServiceSubItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class ServiceCategoryItem {
  final String id;
  final String title; // e.g. "Cleaning Services"
  final String shortTitle; // e.g. "Cleaning"
  final IconData icon;
  final List<ServiceSubItem> subServices;

  const ServiceCategoryItem({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.icon,
    required this.subServices,
  });
}

final List<ServiceCategoryItem> serviceCatalog = [
  const ServiceCategoryItem(
    id: 'cleaning',
    title: 'Cleaning Services',
    shortTitle: 'Cleaning',
    icon: Icons.cleaning_services_outlined,
    subServices: [
      ServiceSubItem(
        id: 'home_cleaning',
        title: 'Home cleaning',
        description: 'Professional Home cleaning services',
        icon: Icons.home_work_outlined,
      ),
      ServiceSubItem(
        id: 'deep_cleaning',
        title: 'Deep cleaning',
        description: 'Professional Deep cleaning services',
        icon: Icons.sanitizer_outlined,
      ),
      ServiceSubItem(
        id: 'kitchen_cleaning',
        title: 'Kitchen & appliance cleaning',
        description: 'Professional Kitchen & appliance cleaning services',
        icon: Icons.countertops_outlined,
      ),
      ServiceSubItem(
        id: 'dish_washing',
        title: 'Dish washing & utensils cleaning',
        description: 'Professional Dish washing & utensils cleaning services',
        icon: Icons.soup_kitchen_outlined,
      ),
      ServiceSubItem(
        id: 'glass_cleaning',
        title: 'Glass & outdoor cleaning',
        description: 'Professional Glass & outdoor cleaning services',
        icon: Icons.window_outlined,
      ),
      ServiceSubItem(
        id: 'sanitation',
        title: 'Sanitation / Disinfection',
        description: 'Professional Sanitation / Disinfection services',
        icon: Icons.coronavirus_outlined,
      ),
      ServiceSubItem(
        id: 'post_construction',
        title: 'Post construction cleaning',
        description: 'Professional Post construction cleaning services',
        icon: Icons.apartment_outlined,
      ),
    ],
  ),
  const ServiceCategoryItem(
    id: 'electrical',
    title: 'Electrical Services',
    shortTitle: 'Electrical',
    icon: Icons.bolt_outlined,
    subServices: [
      ServiceSubItem(
        id: 'wiring_fuse',
        title: 'Wiring & Fuse Replacement',
        description: 'Professional Wiring & Fuse Replacement services',
        icon: Icons.cable_outlined,
      ),
      ServiceSubItem(
        id: 'mcb_panel',
        title: 'MCB & Breaker Panel',
        description: 'Distribution board & breaker trip fault repair',
        icon: Icons.electric_meter_outlined,
      ),
      ServiceSubItem(
        id: 'switchboard',
        title: 'Switchboard & Socket Repair',
        description: 'Modular switch, power socket & dimmer fixes',
        icon: Icons.power_outlined,
      ),
      ServiceSubItem(
        id: 'fan_light',
        title: 'Ceiling Fan & Light Fitting',
        description: 'Ceiling fans, chandeliers & ambient light installation',
        icon: Icons.light_outlined,
      ),
      ServiceSubItem(
        id: 'inverter_ups',
        title: 'Inverter & UPS Maintenance',
        description: 'Battery backup check, inverter wiring & repair',
        icon: Icons.battery_charging_full_outlined,
      ),
      ServiceSubItem(
        id: 'electrical_fault',
        title: 'General Electrical Fault',
        description: 'Short circuit diagnosis & earth leakage resolution',
        icon: Icons.electrical_services_outlined,
      ),
    ],
  ),
  const ServiceCategoryItem(
    id: 'plumbing',
    title: 'Plumbing Services',
    shortTitle: 'Plumbing',
    icon: Icons.plumbing_outlined,
    subServices: [
      ServiceSubItem(
        id: 'tap_valve',
        title: 'Tap & Valve Repair',
        description: 'Continuous dripping tap, brass mixer & shutoff fixes',
        icon: Icons.water_drop_outlined,
      ),
      ServiceSubItem(
        id: 'pipe_leak',
        title: 'Pipe Leakage & Clog Removal',
        description: 'Under-sink leak, drain clog & pipe block removal',
        icon: Icons.waves_outlined,
      ),
      ServiceSubItem(
        id: 'bath_kitchen',
        title: 'Bathroom & Kitchen Fitting',
        description: 'Faucets, hand shower, sink & sanitary installations',
        icon: Icons.bathtub_outlined,
      ),
      ServiceSubItem(
        id: 'geyser_setup',
        title: 'Water Heater / Geyser Setup',
        description: 'Geyser installation, inlet-outlet connection & fixes',
        icon: Icons.hot_tub_outlined,
      ),
      ServiceSubItem(
        id: 'tank_pump',
        title: 'Water Tank & Pump Repair',
        description: 'Overhead tank cleaning & water motor pump servicing',
        icon: Icons.water_damage_outlined,
      ),
    ],
  ),
  const ServiceCategoryItem(
    id: 'appliance',
    title: 'Appliance Repair',
    shortTitle: 'Appliance Repair',
    icon: Icons.kitchen_outlined,
    subServices: [
      ServiceSubItem(
        id: 'washing_machine',
        title: 'Washing Machine Repair',
        description: 'Front-load, top-load, spin cycle & drain repairs',
        icon: Icons.local_laundry_service_outlined,
      ),
      ServiceSubItem(
        id: 'refrigerator',
        title: 'Refrigerator Servicing',
        description: 'Cooling issues, compressor, defrost & gas charging',
        icon: Icons.kitchen_outlined,
      ),
      ServiceSubItem(
        id: 'air_conditioner',
        title: 'Air Conditioner (AC) Repair',
        description: 'AC deep jet cleaning, gas charging & cooling repair',
        icon: Icons.ac_unit_outlined,
      ),
      ServiceSubItem(
        id: 'microwave',
        title: 'Microwave & Oven Repair',
        description: 'Heating element, magnetron, door & turntable repair',
        icon: Icons.microwave_outlined,
      ),
      ServiceSubItem(
        id: 'water_purifier',
        title: 'Water Purifier / RO Service',
        description: 'RO membrane replacement, filter change & TDS balance',
        icon: Icons.water_outlined,
      ),
    ],
  ),
];
