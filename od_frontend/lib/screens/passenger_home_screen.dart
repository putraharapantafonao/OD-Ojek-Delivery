import 'package:flutter/material.dart';
import '../services/order_service.dart';

class PassengerHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const PassengerHomeScreen({super.key, required this.user});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  String _selectedService = 'od_ride'; // Default Ojek
  String _selectedPayment = 'cash'; // Default Tunai
  bool _isLoading = false;

  final _orderService = OrderService();

  void _submitOrder() async {
    if (_pickupController.text.trim().isEmpty || _dropoffController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi jemput dan tujuan wajib diisi!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi perhitungan harga berdasarkan panjang karakter (hanya dummy)
    final double calculatedPrice = (_pickupController.text.length + _dropoffController.text.length) * 1500.0;

    final result = await _orderService.createOrder(
      serviceType: _selectedService,
      pickupLocation: _pickupController.text.trim(),
      dropoffLocation: _dropoffController.text.trim(),
      price: calculatedPrice < 5000 ? 5000 : calculatedPrice, // Min Rp5.000
      paymentMethod: _selectedPayment,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Kosongkan form jika sukses
      _pickupController.clear();
      _dropoffController.clear();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pesanan Dibuat!'),
          content: Text('Sedang mencari driver terdekat...\n\nHarga: Rp ${result['order']['price']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Halo, ${widget.user['name']}! 👋', style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF00B14F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Profil / Logout
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Hijau Atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF00B14F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Text(
                'Mau pergi ke mana\nhari ini?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            
            // Form Pemesanan Card
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pilihan Layanan
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedService = 'od_ride'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedService == 'od_ride' ? const Color(0xFFE8F5E9) : Colors.transparent,
                                border: Border.all(
                                  color: _selectedService == 'od_ride' ? const Color(0xFF00B14F) : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.motorcycle, color: _selectedService == 'od_ride' ? const Color(0xFF00B14F) : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text('OD-Ride', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedService == 'od_ride' ? const Color(0xFF00B14F) : Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedService = 'od_send'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedService == 'od_send' ? const Color(0xFFE8F5E9) : Colors.transparent,
                                border: Border.all(
                                  color: _selectedService == 'od_send' ? const Color(0xFF00B14F) : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.local_shipping, color: _selectedService == 'od_send' ? const Color(0xFF00B14F) : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text('OD-Send', style: TextStyle(fontWeight: FontWeight.bold, color: _selectedService == 'od_send' ? const Color(0xFF00B14F) : Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Input Lokasi
                    TextField(
                      controller: _pickupController,
                      decoration: const InputDecoration(
                        labelText: 'Titik Jemput (Misal: Gedung A)',
                        prefixIcon: Icon(Icons.my_location, color: Colors.blue),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dropoffController,
                      decoration: const InputDecoration(
                        labelText: 'Tujuan (Misal: Kos Pak Andi)',
                        prefixIcon: Icon(Icons.location_on, color: Colors.red),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dropdown Pembayaran
                    const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPayment,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'cash', child: Text('Tunai / Cash')),
                            DropdownMenuItem(value: 'ewallet', child: Text('E-Wallet (OVO/GoPay/Dana)')),
                            DropdownMenuItem(value: 'transfer', child: Text('Transfer Bank')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPayment = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Tombol Pesan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B14F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('PESAN SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
