import 'package:adoptnest/app/themes/font_data.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onAdoptTap;

  const DashboardScreen({super.key, this.onAdoptTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20), // extra padding for FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome back", style: FontData.body2),
                    const SizedBox(height: 4),
                    Text("Hello", style: FontData.header1),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 28),
                ),
              ],
            ),
          ),

          // Hero Card
          Container(
            height: 270,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  "https://hips.hearstapps.com/hmg-prod/images/dog-puppy-on-garden-royalty-free-image-1586966191.jpg",
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Container(color: Colors.black.withOpacity(0.25)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Help a stray today",
                          style: FontData.header2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Every small act of kindness makes a huge difference in a life.",
                          style: FontData.body2.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Help a Stray"),
                                content: const Text(
                                    "Every small act of kindness can save a life! Volunteer, adopt, or donate to local shelters."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: const Text("Learn More"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Adopt Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdoptTap,
                icon: const Icon(Icons.pets, color: Colors.pink),
                label: Text("Adopt", style: FontData.body1.copyWith(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Featured Animals Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Animals Needing Help", style: FontData.header2),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildAnimalCard(
                        name: "Bella",
                        type: "Dog",
                        issue: "Injured",
                        imageUrl:
                            "https://www.borrowmydoggy.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2F4ij0poqn%2Fproduction%2Fe24bfbd855cda99e303975f2bd2a1bf43079b320-800x600.jpg&w=1080&q=80",
                      ),
                      _buildAnimalCard(
                        name: "Luna",
                        type: "Cat",
                        issue: "Needs home",
                        imageUrl:
                            "https://www.scottishspca.org/wp-content/uploads/2024/09/CATS-INVERNESS-JUNE-24-13-1369x913.jpg",
                      ),
                      _buildAnimalCard(
                        name: "Charlie",
                        type: "Dog",
                        issue: "Abandoned",
                        imageUrl:
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKHZKP5evJdJ_ptEGnEIhJ4WgHCNesk0S9IQ&s",
                      ),
                      _buildAnimalCard(
                        name: "Toofan",
                        type: "Horse",
                        issue: "Abused",
                        imageUrl:
                            "https://cdn.shopify.com/s/files/1/0765/3946/1913/files/depressed_horse.png?v=1733171444",
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard({
    required String name,
    required String type,
    required String issue,
    required String imageUrl,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: FontData.header3),
                const SizedBox(height: 4),
                Text(type, style: FontData.body2),
                Text(issue, style: FontData.body2),
              ],
            ),
          )
        ],
      ),
    );
  }
}
