import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/destination.dart';
import '../utils/app_utils.dart';
import '../services/realtime_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;
  final Destination destination;

  const BookingDetailScreen({
    super.key,
    required this.booking,
    required this.destination,
  });

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late int _modifiedNumPeople;
  late DateTime _modifiedDate;
  bool _isModified = false;
  final RealtimeService _realtimeService = RealtimeService();

  @override
  void initState() {
    super.initState();
    _modifiedNumPeople = widget.booking.numPeople;
    _modifiedDate = widget.booking.date;
  }

  double _calculateAdditionalFee() {
    double additionalFee = 0;
    
    // Phí thay đổi số người: $5 per person
    int peopleIncrease = _modifiedNumPeople - widget.booking.numPeople;
    if (peopleIncrease > 0) {
      additionalFee += peopleIncrease * 5;
    }
    
    // Phí thay đổi ngày: $10 per day (nếu đổi ngày)
    if (_modifiedDate != widget.booking.date) {
      additionalFee += 10;
    }
    
    return additionalFee;
  }

  double _calculateNewPrice() {
    return (widget.destination.price + _calculateAdditionalFee());
  }
  @override
  Widget build(BuildContext context) {
    final bookingDate = widget.booking.date;
    final formattedDate = AppUtils.formatDate(bookingDate);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.destination.imageUrls.isNotEmpty)
                    Image.network(
                      widget.destination.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.landscape, size: 80)),
                          ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.landscape, size: 80)),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Booking details
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination info
                  Text(
                    widget.destination.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.teal.shade600),
                      const SizedBox(width: 6),
                      Text(
                        widget.destination.location,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Booking status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Booking Confirmed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Booking details section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Booking ID', widget.booking.id.substring(0, 8)),
                  _buildDetailRow('Check-in Date', formattedDate),
                  _buildDetailRow('Number of Guests', '${widget.booking.numPeople} ${widget.booking.numPeople == 1 ? 'person' : 'people'}'),
                  _buildDetailRow('Price per Night', '\$${widget.destination.price.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          // Destination info section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Destination',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.destination.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              widget.destination.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.destination.favoritesCount}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showModifyBookingDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Modify Booking',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [bool isChanged = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isChanged ? Colors.teal.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
            },
            child: Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  void _showModifyBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modify Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Date Section
                const Text(
                  'Check-in Date',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _modifiedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _modifiedDate = selectedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppUtils.formatDate(_modifiedDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Number of People Section
                const Text(
                  'Number of People',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _modifiedNumPeople > 1
                          ? () {
                              setState(() => _modifiedNumPeople--);
                            }
                          : null,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_modifiedNumPeople people',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() => _modifiedNumPeople++);
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fee Breakdown Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price Breakdown',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      _buildFeeRow(
                        'Base Price',
                        '\$${widget.destination.price.toStringAsFixed(2)}',
                      ),
                      if (_modifiedNumPeople > widget.booking.numPeople)
                        _buildFeeRow(
                          'Additional People (+${_modifiedNumPeople - widget.booking.numPeople})',
                          '\$${((_modifiedNumPeople - widget.booking.numPeople) * 5).toStringAsFixed(2)}',
                          color: Colors.orange,
                        ),
                      if (_modifiedDate != widget.booking.date)
                        _buildFeeRow(
                          'Date Change Fee',
                          '\$10.00',
                          color: Colors.orange,
                        ),
                      const Divider(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Total',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '\$${_calculateNewPrice().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _calculateAdditionalFee() > 0
                  ? () {
                      Navigator.pop(context);
                      _showModifyConfirmation();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showModifyConfirmation() {
    final additionalFee = _calculateAdditionalFee();
    final newPrice = _calculateNewPrice();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your changes:'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Check-in Date',
              AppUtils.formatDate(_modifiedDate),
              _modifiedDate != widget.booking.date,
            ),
            _buildDetailRow(
              'Number of People',
              '$_modifiedNumPeople people',
              _modifiedNumPeople != widget.booking.numPeople,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Additional Charge',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${additionalFee.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Total Price',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  Text(
                    '\$${newPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Update booking to database
                await _realtimeService.updateBooking(widget.booking.id, {
                  'date': _modifiedDate.toIso8601String(),
                  'numPeople': _modifiedNumPeople,
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Reload booking detail screen
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pop(context);
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating booking: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm & Pay'),
          ),
        ],
      ),
    );
  }
}
