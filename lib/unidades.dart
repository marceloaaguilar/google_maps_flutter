import 'package:flutter/material.dart';

class Unidades extends StatelessWidget {
  final List<Map<String, String>> unidades = [
    {
      "nome": "Barreiro",
      "endereco": "Av. Afonso Vaz de Melo, 1200 - Barreiro",
    },
    {
      "nome": "Betim",
      "endereco": "R. do Rosário, 1081 - Angola, Betim",
    },
    {
      "nome": "Contagem",
      "endereco": "R. Rio Comprido, 4.580 - Contagem",
    },
    {
      "nome": "Coração Eucarístico",
      "endereco": "Av. Dom José Gaspar, 500 - Coração Eucarístico",
    },
    {
      "nome": "Lourdes",
      "endereco": "Rua Cláudio Manoel, 1.162 - Bairro Savassi - Lourdes",
    },
    {
      "nome": "São Gabriel",
      "endereco": "Anel Rodoviário Km 23,5 - Rua Walter Ianni, 255 - São Gabriel",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unidades PUC Minas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: unidades.length,
          itemBuilder: (context, index) {
            final unidade = unidades[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unidade["nome"]!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      unidade["endereco"]!,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
