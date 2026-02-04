// screens/my_events_screen.dart (With Image)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Map<String, dynamic>> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  void _loadRegisteredEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final registeredEventsJson = prefs.getStringList('registeredEvents') ?? [];

    setState(() {
      registeredEvents = registeredEventsJson.map((json) {
        return Map<String, dynamic>.from(jsonDecode(json));
      }).toList();
    });
  }

  void _cancelEvent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: Text(
            'Are you sure you want to cancel registration for ${registeredEvents[index]['title']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _removeEvent(index);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeEvent(int index) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      registeredEvents.removeAt(index);
    });

    final updatedJsonList = registeredEvents.map((event) => jsonEncode(event)).toList();
    await prefs.setStringList('registeredEvents', updatedJsonList);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event registration cancelled'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: registeredEvents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'No events registered yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registeredEvents.length,
        itemBuilder: (context, index) {
          final event = registeredEvents[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.deepPurple[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: event['image'] != null
                      ? Image.network(
                    event['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.event,
                          color: Colors.deepPurple,
                          size: 24,
                        ),
                      );
                    },
                  )
                      : Center(
                    child: Icon(
                      Icons.event,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                ),
              ),
              title: Text(
                event['title'] ?? 'No title',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    event['date'] ?? 'Date not available',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event['location'] ?? 'Location not available',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Registered',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _cancelEvent(index),
              ),
            ),
          );
        },
      ),
    );
  }
}