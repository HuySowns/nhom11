import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../models/booking.dart';
import '../services/auth_provider.dart';
import '../services/realtime_service.dart';

class BookingScreen extends StatefulWidget {
  final Destination destination;

  const BookingScreen({super.key, required this.destination});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _numPeople = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Destination')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking for ${widget.destination.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Travel Date'),
                subtitle: Text(_selectedDate.toLocal().toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Number of People:'),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _numPeople,
                    items: List.generate(10, (index) => index + 1)
                        .map((num) => DropdownMenuItem(
                              value: num,
                              child: Text(num.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _numPeople = value!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Total Price: \$${_calculateTotalPrice()}'),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _book,
                      child: const Text('Confirm Booking'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  double _calculateTotalPrice() {
    return widget.destination.price * _numPeople;
  }

  Future<void> _book() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final booking = Booking(
        id: '', // Will be set by Realtime DB
        userId: user.uid,
        destinationId: widget.destination.id,
        date: _selectedDate,
        numPeople: _numPeople,
      );
      await RealtimeService().addBooking(booking);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}