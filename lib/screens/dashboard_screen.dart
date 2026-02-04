// screens/dashboard_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ass_3/widgets/custom_drawer.dart';
import 'package:ass_3/widgets/event_card.dart';
import 'package:ass_3/screens/my_events_screen.dart';
import 'package:ass_3/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeTab(),
    const MyEventsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventBuzz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final List<Map<String, dynamic>> events = [
    {
      'id': '1',
      'title': 'Tech Conference 2024',
      'date': 'Dec 15, 2024',
      'location': 'San Francisco, CA',
      'image': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      'isRegistered': false,
    },
    {
      'id': '2',
      'title': 'Music Festival',
      'date': 'Jan 20, 2025',
      'location': 'Austin, TX',
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      'isRegistered': false,
    },
    {
      'id': '3',
      'title': 'Startup Pitch',
      'date': 'Nov 30, 2024',
      'location': 'New York, NY',
      'image': 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=800',
      'isRegistered': false,
    },
    {
      'id': '4',
      'title': 'Art Exhibition',
      'date': 'Feb 10, 2025',
      'location': 'Paris, France',
      'image': 'https://images.unsplash.com/photo-1563089145-599997674d42?w=800',
      'isRegistered': false,
    },
    {
      'id': '5',
      'title': 'Food Festival',
      'date': 'Mar 05, 2025',
      'location': 'Tokyo, Japan',
      'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      'isRegistered': false,
    },
  ];

  Future<void> _registerEvent(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current registered events
    final registeredEventsJson = prefs.getStringList('registeredEvents') ?? [];
    List<Map<String, dynamic>> registeredEvents = [];

    for (var json in registeredEventsJson) {
      registeredEvents.add(Map<String, dynamic>.from(jsonDecode(json)));
    }

    // ✅ અહીં image URL સાથે event save કરો
    final eventToRegister = {
      'id': events[index]['id'],
      'title': events[index]['title'],
      'date': events[index]['date'],
      'location': events[index]['location'],
      'image': events[index]['image'], // ✅ Image URL
      'registeredDate': DateTime.now().toIso8601String(),
    };

    // Check if already registered
    bool alreadyRegistered = registeredEvents.any((event) => event['id'] == events[index]['id']);

    if (!alreadyRegistered) {
      registeredEvents.add(eventToRegister);

      // Save updated list to SharedPreferences
      final updatedJsonList = registeredEvents.map((event) => jsonEncode(event)).toList();
      await prefs.setStringList('registeredEvents', updatedJsonList);

      // Update local state
      setState(() {
        events[index]['isRegistered'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered for ${events[index]['title']}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already registered for ${events[index]['title']}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRegistrationStatus();
  }

  void _loadRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredEventsJson = prefs.getStringList('registeredEvents') ?? [];
    List<Map<String, dynamic>> registeredEvents = [];

    for (var json in registeredEventsJson) {
      registeredEvents.add(Map<String, dynamic>.from(jsonDecode(json)));
    }

    // Update local events registration status
    for (var i = 0; i < events.length; i++) {
      bool isRegistered = registeredEvents.any((event) => event['id'] == events[i]['id']);
      if (isRegistered) {
        setState(() {
          events[i]['isRegistered'] = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EventCard(
                  imageUrl: event['image']!,
                  title: event['title']!,
                  date: event['date']!,
                  location: event['location']!,
                  isRegistered: event['isRegistered'],
                  onRegister: () => _registerEvent(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}