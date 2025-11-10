import 'package:flutter/material.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _clienteSeleccionado;
  String? _metodoPagoSeleccionado;

  final List<String> _clientes = [
    'Juan Pérez',
    'María Gómez',
    'Carlos López',
    'Cliente nuevo',
  ];

  final List<String> _metodosPago = [
    'Efectivo',
    'Tarjeta de crédito',
    'Tarjeta de débito',
    'Transferencia bancaria',
    'Mercado Pago',
  ];

  final List<Map<String, dynamic>> _carrito = [];

  double get _total => _carrito.fold(
    0,
        (suma, item) =>
    suma + (item['cantidad'] as int) * (item['precio'] as double),
  );

  // ---------------- AGREGAR PRODUCTO ----------------
  void _agregarProducto() {
    final TextEditingController productoCtrl = TextEditingController();
    final TextEditingController cantidadCtrl = TextEditingController();
    final TextEditingController precioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productoCtrl,
              decoration: const InputDecoration(labelText: 'Producto'),
            ),
            TextField(
              controller: cantidadCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio unitario'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = productoCtrl.text.trim();
              final cantidad = int.tryParse(cantidadCtrl.text) ?? 0;
              final precio = double.tryParse(precioCtrl.text) ?? 0;

              if (nombre.isNotEmpty && cantidad > 0 && precio > 0) {
                setState(() {
                  _carrito.add({
                    'nombre': nombre,
                    'cantidad': cantidad,
                    'precio': precio,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // ---------------- GUARDAR VENTA ----------------
  void _guardarVenta() {
    if (_clienteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un cliente')),
      );
      return;
    }

    if (_metodoPagoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un método de pago')),
      );
      return;
    }

    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un producto')),
      );
      return;
    }

    // TODO: Enviar los datos a la API o base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Venta guardada ✅ (${_carrito.length} productos, total: \$${_total.toStringAsFixed(2)})'),
      ),
    );

    Navigator.pop(context);
  }

  // ---------------- ELIMINAR PRODUCTO ----------------
  void _eliminarProducto(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  // ---------------- INTERFAZ ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- CLIENTE ----
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                value: _clienteSeleccionado,
                items: _clientes
                    .map((cliente) => DropdownMenuItem(
                  value: cliente,
                  child: Text(cliente),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _clienteSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ---- MÉTODO DE PAGO ----
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Método de pago',
                  prefixIcon: Icon(Icons.payment_outlined),
                ),
                value: _metodoPagoSeleccionado,
                items: _metodosPago
                    .map((pago) => DropdownMenuItem(
                  value: pago,
                  child: Text(pago),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _metodoPagoSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ---- LISTA DE PRODUCTOS ----
              Expanded(
                child: _carrito.isEmpty
                    ? const Center(
                  child: Text(
                    'No hay productos en el carrito',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: _carrito.length,
                  itemBuilder: (context, index) {
                    final item = _carrito[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.shopping_bag_outlined),
                        title: Text(item['nombre']),
                        subtitle: Text(
                            'Cantidad: ${item['cantidad']}  |  \$${item['precio'].toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _eliminarProducto(index),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ---- TOTAL ----
              const SizedBox(height: 8),
              Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // ---- BOTONES ----
              ElevatedButton.icon(
                onPressed: _agregarProducto,
                icon: const Icon(Icons.add),
                label: const Text('Agregar producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _guardarVenta,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Guardar venta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
